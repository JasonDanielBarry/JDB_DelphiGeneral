unit XMLFileReaderWriter;

interface

    uses
        system.SysUtils,
        Xml.XMLDoc,
        Xml.XMLIntf,
        XMLNodeWrapper
        ;

    type
        TXMLFileReaderWriter = record
            private
                const
                    ROOT_STRING     : string = 'DocumentRoot';
                    VALUE_STRING    : string = 'Value';
                var
                    XMLFileDocument : IXMLDocument;
                    wrappedRootNode : TWrappedXMLNode;
            public
                //initialise the document to save data
                    function initialiseXMLDocument() : boolean;
                //load XML file
                    function loadFile(const fileNameIn : string) : boolean;
                //save file
                    procedure saveFile(const fileNameIn : string);
                //document root node
                    property RootNode : TWrappedXMLNode read wrappedRootNode;
        end;

implementation

    uses
        System.Win.ComObj;

    //private
        //initialise the document to save data
            function TXMLFileReaderWriter.initialiseXMLDocument() : boolean;
                var
                    rootXMLNode : IXMLNode;
                begin
                    result := False;

                    //check document creation is successful
                        XMLFileDocument := NewXMLDocument();

                        if NOT( Assigned(XMLFileDocument) ) then
                            exit( False );

                    //configure options
                        XMLFileDocument.Options := XMLFileDocument.Options + [doNodeAutoIndent];
                        XMLFileDocument.Active  := True;

                    //assign root node
                        rootXMLNode := XMLFileDocument.AddChild( ROOT_STRING );
                        wrappedRootNode.setXMLNode( rootXMLNode );

                    result := True;
                end;

    //public
        //file methods
            //load file
                function TXMLFileReaderWriter.loadFile(const fileNameIn : string) : boolean;
                    var
                        fileDoesNotExist    : boolean;
                        rootXMLNode         : IXMLNode;
                    begin
                        result := False;

                        //check that the file exist
                            fileDoesNotExist := NOT( FileExists( fileNameIn ) );

                            if ( fileDoesNotExist ) then
                                exit( False );

                        //load in the XML file
                            XMLFileDocument := LoadXMLDocument( fileNameIn );

                            if NOT( Assigned( XMLFileDocument.DocumentElement ) ) then
                                exit( False );

                            XMLFileDocument.Active := True;

                        //get the root node
                            rootXMLNode := XMLFileDocument.DocumentElement;

                            wrappedRootNode.setXMLNode( rootXMLNode );

                        result := True;
                    end;

            //save file
                procedure TXMLFileReaderWriter.saveFile(const fileNameIn : string);
                    begin
                        //save the document
                            XMLFileDocument.SaveToFile( fileNameIn );
                    end;

end.
