unit TreeNodeBaseClass;

interface

    uses
        System.SysUtils, System.Rtti, System.Generics.Collections,
        Xml.XMLIntf,
        TreeStructureTypes
        ;

    type
        TTreeNodeBase = class
            private
                type
                    TChildNodeMap = TOrderedDictionary<string, TTreeNodeBase>;
                var
                    storedValue,
                    storedValueType : string;
                    childNodesMap   : TChildNodeMap;
                //reset child nodes
                    procedure resetChildNodes();
            protected
                //access stored value and type
                    //write a value to self
                        procedure writeToStoredValueAndType(const valueStringIn, valueTypeIn : string);
                    //read self's stored value
                        procedure readStoredValueAndType(out valueStringOut, valueTypeOut : string);
                //child node manipulation
                    //try create a new child node
                        function tryCreateNewChildNode(const childNodeIdentifierIn : string; out newChildNodeOut : TTreeNodeBase) : boolean;
                    //try get a child node
                        function tryGetChildNode(const childNodeIdentifierIn : string; out childNodeOut : TTreeNodeBase) : boolean;
            public
                //constructor
                    constructor create();
                //destructor
                    destructor destroy();
                //XML
                    //read from XML node
                        procedure readFromXMLNode(const XMLNodeIn : IXMLNode);
                    //write to XML node
                        procedure writeToXMLNode(const XMLNodeIn : IXMLNode);
        end;

implementation

    //private
        //reset child nodes
            procedure TTreeNodeBase.resetChildNodes();
                var
                    treeNodePair : TPair<string,TTreeNodeBase>;
                begin
                    for treeNodePair in childNodesMap do
                        FreeAndNil( treeNodePair.Value );

                    childNodesMap.Clear();
                end;

    //protected
        //store a value to self
            procedure TTreeNodeBase.writeToStoredValueAndType(const valueStringIn, valueTypeIn : string);
                begin
                    storedValue     := valueStringIn;
                    storedValueType := valueTypeIn;
                end;

        //read self's stored value
            procedure TTreeNodeBase.readStoredValueAndType(out valueStringOut, valueTypeOut : string);
                begin
                    valueStringOut  := storedValue;
                    valueTypeOut    := storedValueType;
                end;


        //try create a new child node
            function TTreeNodeBase.tryCreateNewChildNode(const childNodeIdentifierIn : string; out newChildNodeOut : TTreeNodeBase) : boolean;
                var
                    nodeAlreadyExists : boolean;
                begin
                    result := False;

                    //check for node's existence
                        nodeAlreadyExists := childNodesMap.ContainsKey( childNodeIdentifierIn );

                        if ( nodeAlreadyExists ) then
                            exit( False );

                    //create new node and place in map
                        newChildNodeOut := TTreeNodeBase.create();

                        childNodesMap.AddOrSetValue( childNodeIdentifierIn, newChildNodeOut );

                    result := true;
                end;

        //try get a child node
            function TTreeNodeBase.tryGetChildNode(const childNodeIdentifierIn : string; out childNodeOut : TTreeNodeBase) : boolean;
                begin
                    result := childNodesMap.TryGetValue( childNodeIdentifierIn, childNodeOut );
                end;

    //public
        //constructor
            constructor TTreeNodeBase.create();
                begin
                    inherited create();

                    childNodesMap := TChildNodeMap.Create();
                end;

        //destructor
            destructor TTreeNodeBase.destroy();
                begin
                    resetChildNodes();

                    inherited destroy();
                end;

        //XML
            //read from XML node
                procedure TTreeNodeBase.readFromXMLNode(const XMLNodeIn : IXMLNode);
                    begin

                    end;

            //write to XML node
                procedure TTreeNodeBase.writeToXMLNode(const XMLNodeIn : IXMLNode);
                    begin

                    end;

end.
