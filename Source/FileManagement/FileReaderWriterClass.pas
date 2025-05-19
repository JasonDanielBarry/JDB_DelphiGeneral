unit FileReaderWriterClass;

interface

    uses
        system.SysUtils, system.Classes, system.Generics.Collections, system.StrUtils,
        Xml.XMLDoc, Xml.XMLIntf, xml.xmldom,
        ArrayConversionMethods, XMLDocumentMethods
        ;

    type
        TFileReaderWriter = class
            private
                const
                    ARRAY_ELEMENT_DELIMITER : string = ';';
                    ROOT_STRING             : string = 'Root';
                    VALUE_STRING            : string = 'Value';
                var
                    fileName        : string;
                    XMLFileDocument : IXMLDocument;
            protected
                var
                    rootNode : IXMLNode;
                //reset the document
                    procedure resetXMLDocument();
                //create a new node belonging to the root node
                    function tryCreateNewNode(const nodeIdentifierIn : string; out newXMLNodeOut : IXMLNode) : boolean;
                //check that a node with the identifier exists
                    function checkNodeExists(const nodeIdentifierIn : string) : boolean; overload;
                    function tryGetNode(const nodeIdentifierIn : string; out XMLNodeOut : IXMLNode) : boolean; overload;
                //get an identifier's data type
                    function getNodeType(const nodeIdentifierIn : string) : string;
            public
                //constructor
                    constructor create(const fileNameIn : string); virtual;
                //destructor
                    destructor destroy(); override;
                //file methods
                    //load file
                        function loadFile() : boolean;
                    //save file
                        procedure saveFile();
                //read methods
                    //single values
                        function tryReadBool(const identifierIn : string; out valueOut : boolean; const defaultValueIn : boolean = False) : boolean;
                        function tryReadInteger(const identifierIn : string; out valueOut : integer; const defaultValueIn : integer = 0) : boolean;
                        function tryReadDouble(const identifierIn : string; out valueOut : double; const defaultValueIn : double = 0) : boolean;
                        function tryReadString(const identifierIn : string; out valueOut : string; const defaultValueIn : string = '') : boolean;
                    //arrays
                        function tryReadIntegerArray(const identifierIn : string; out arrayOut : TArray<integer>) : boolean;
                        function tryReadDoubleArray(const identifierIn : string; out arrayOut : TArray<double>) : boolean;
                        function tryReadStringArray(const identifierIn : string; out arrayOut : TArray<string>) : boolean;
                //write methods
                    //single values
                        procedure writeBool(const identifierIn : string; const valueIn : boolean);
                        procedure writeInteger(const identifierIn : string; const valueIn : integer);
                        procedure writeDouble(const identifierIn : string; const valueIn : double);
                        procedure writeString(const identifierIn, valueIn : string); overload;
                    //arrays
                        procedure writeIntegerArray(const identifierIn : string; const arrayIn : TArray<integer>);
                        procedure writeDoubleArray(const identifierIn : string; const arrayIn : TArray<double>);
                        procedure writeStringArray(const identifierIn : string; const arrayIn : TArray<string>);
        end;

implementation

    //protected
        //reset the document
            procedure TFileReaderWriter.resetXMLDocument();
                begin
                    XMLFileDocument         := NewXMLDocument();
                    XMLFileDocument.Options := XMLFileDocument.Options + [doNodeAutoIndent];
                    XMLFileDocument.Active  := True;
                    rootNode                := XMLFileDocument.AddChild( ROOT_STRING );
                end;

        //create a new node belonging to the root node
            function TFileReaderWriter.tryCreateNewNode(const nodeIdentifierIn : string; out newXMLNodeOut : IXMLNode) : boolean;
                begin
                    //check if the node already exists
                        if NOT( tryCreateNewXMLChildNode( rootNode, nodeIdentifierIn, newXMLNodeOut ) ) then
                            exit( False );

                    result := True;
                end;

        //check that a node exists
            function TFileReaderWriter.checkNodeExists(const nodeIdentifierIn : string) : boolean;
                var
                    dummyNode : IXMLNode;
                begin
                    result := tryGetNode( nodeIdentifierIn, dummyNode );
                end;

            function TFileReaderWriter.tryGetNode(const nodeIdentifierIn : string; out XMLNodeOut : IXMLNode) : boolean;
                begin
                    //get the node
                        XMLNodeOut := rootNode.ChildNodes.FindNode( nodeIdentifierIn );

                    //if item node = nil then the node does not exist
                        result := Assigned( XMLNodeOut );
                end;

        //get an identifier's data type
            function TFileReaderWriter.getNodeType(const nodeIdentifierIn : string) : string;
                var
                    itemNode : IXMLNode;
                begin
                    tryGetNode( nodeIdentifierIn, itemNode );

                    result := getXMLNodeDataType( itemNode );
                end;

    //public
        //constructor
            constructor TFileReaderWriter.create(const fileNameIn : string);
                begin
                    inherited create();

                    fileName := fileNameIn;

                    resetXMLDocument();
                end;

        //destructor
            destructor TFileReaderWriter.destroy();
                begin
                    inherited destroy();
                end;

        //file methods
            //load file
                function TFileReaderWriter.loadFile() : boolean;
                    var
                        fileDoesNotExist : boolean;
                    begin
                        //check that the file exist
                            fileDoesNotExist := NOT( FileExists( fileName ) );

                            if ( fileDoesNotExist ) then
                                exit( false );

                        //load in the XML file
                            XMLFileDocument := LoadXMLDocument( fileName );

                            XMLFileDocument.Active := True;

                        //get the root node
                            rootNode := XMLFileDocument.DocumentElement;

                        result := True;
                    end;

            //save file
                procedure TFileReaderWriter.saveFile();
                    begin
                        //save the document
                            XMLFileDocument.SaveToFile( fileName );
                    end;

        //read methods
            //single values
                function TFileReaderWriter.tryReadBool(const identifierIn : string; out valueOut : boolean; const defaultValueIn : boolean = False) : boolean;
                    begin
                        result := tryReadBooleanFromXMLNode( rootNode, identifierIn, valueOut, defaultValueIn );
                    end;

                function TFileReaderWriter.tryReadInteger(const identifierIn : string; out valueOut : integer; const defaultValueIn : integer = 0) : boolean;
                    begin
                        result := tryReadIntegerFromXMLNode( rootNode, identifierIn, valueOut, defaultValueIn );
                    end;

                function TFileReaderWriter.tryReadDouble(const identifierIn : string; out valueOut : double; const defaultValueIn : double = 0) : boolean;
                    begin
                        result := tryReadDoubleFromXMLNode( rootNode, identifierIn, valueOut, defaultValueIn );
                    end;

                function TFileReaderWriter.tryReadString(const identifierIn : string; out valueOut : string; const defaultValueIn : string = '') : boolean;
                    begin
                        result := tryReadStringFromXMLNode( rootNode, identifierIn, valueOut, defaultValueIn );
                    end;

            //arrays
                function TFileReaderWriter.tryReadIntegerArray(const identifierIn : string; out arrayOut : TArray<integer>) : boolean;
                    begin
                        result := TryReadIntegerArrayFromXMLNode( rootNode, identifierIn, arrayOut );
                    end;

                function TFileReaderWriter.tryReadDoubleArray(const identifierIn : string; out arrayOut : TArray<double>) : boolean;
                    begin
                        result := TryReadDoubleArrayFromXMLNode( rootNode, identifierIn, arrayOut );
                    end;

                function TFileReaderWriter.tryReadStringArray(const identifierIn : string; out arrayOut : TArray<string>) : boolean;
                    begin
                        result := TryReadStringArrayFromXMLNode( rootNode, identifierIn, arrayOut );
                    end;

        //write methods
            //single values
                procedure TFileReaderWriter.writeBool(const identifierIn : string; const valueIn : boolean);
                    begin
                        writeBooleanToXMLNode( rootNode, identifierIn, valueIn );
                    end;

                procedure TFileReaderWriter.writeInteger(const identifierIn : string; const valueIn : integer);
                    begin
                        writeIntegerToXMLNode( rootNode, identifierIn, valueIn );
                    end;

                procedure TFileReaderWriter.writeDouble(const identifierIn : string; const valueIn : double);
                    begin
                        writeDoubleToXMLNode( rootNode, identifierIn, valueIn );
                    end;

                procedure TFileReaderWriter.writeString(const identifierIn, valueIn : string);
                    begin
                        writeStringToXMLNode( rootNode, identifierIn, valueIn );
                    end;

            //arrays
                procedure TFileReaderWriter.writeIntegerArray(const identifierIn : string; const arrayIn : TArray<integer>);
                    begin
                        writeIntegerArrayToXMLNode( rootNode, identifierIn, arrayIn );
                    end;

                procedure TFileReaderWriter.writeDoubleArray(const identifierIn : string; const arrayIn : TArray<double>);
                    begin
                        writeDoubleArrayToXMLNode( rootNode, identifierIn, arrayIn );
                    end;

                procedure TFileReaderWriter.writeStringArray(const identifierIn : string; const arrayIn : TArray<string>);
                    begin
                        writeStringArrayToXMLNode( rootNode, identifierIn, arrayIn );
                    end;

end.
