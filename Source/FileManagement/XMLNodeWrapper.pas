unit XMLNodeWrapper;

interface

    uses
        system.SysUtils, system.StrUtils,
        Xml.XMLIntf,
        ArrayConversionMethods;

    type
        TWrappedXMLNode = record
            strict private
                var
                    wrappedXMLDataNode : IXMLNode;
                //child node
                    //try get a child node
                        function tryGetChildNode(const childNodeIdentifierIn : string; out childNodeOut : TWrappedXMLNode) : boolean; overload;
                    //create new child node
                        function tryCreateNewChild(const childNodeIdentifierIn : string; out newChildNodeOut : TWrappedXMLNode) : boolean; overload;
                //read from nodes
                    //read value from node
                        function tryReadValue(const dataIdentifierIn, valueTypeIn : string; out valueOut : string) : boolean;
                    //read array
                        function tryReadArray(const dataIdentifierIn, arrayTypeIn : string; out valuesArrayOut : TArray<string>) : boolean;
                //write to node
                    //write value to node
                        procedure writeValue(const dataIdentifierIn, valueTypeIn, valueIn : string);
                    //write array to node
                        procedure writeArray(const dataIdentifierIn, arrayTypeIn : string; valuesArrayIn : TArray<string>);
            public
                //set the XML node
                    procedure setXMLNode(const newXMLNodeIn : IXMLNode);
                //read data from XML node
                    //try get a parent node's child node
                        function tryGetChildNode(const childNodeIdentifierIn, childNodeDataTypeIn : string; out childNodeOut : TWrappedXMLNode) : boolean; overload;
                    //data type
                        function isDataType(const nodeDataTypeIn : string) : boolean;
                        function getDataType() : string;
                    //boolean
                        function tryReadBoolean(const dataIdentifierIn : string; out boolValueOut : boolean; const defaultValueIn : boolean = False) : boolean;
                    //integer
                        function tryReadInteger(const dataIdentifierIn : string; out integerValueOut : integer; const defaultValueIn : integer = 0) : boolean;
                    //double
                        function tryReadDouble(const dataIdentifierIn : string; out doubleValueOut : double; const defaultValueIn : double = 0) : boolean;
                    //string
                        function tryReadString(const dataIdentifierIn : string; out stringValueOut : string; const defaultValueIn : string = '') : boolean;
                    //arrays
                        //integer
                            function TryReadIntegerArray(const dataIdentifierIn : string; out integerArrayOut : TArray<integer>) : boolean;
                        //double
                            function TryReadDoubleArray(const dataIdentifierIn : string; out doubleArrayOut : TArray<double>) : boolean;
                        //string
                            function TryReadStringArray(const dataIdentifierIn : string; out stringArrayOut : TArray<string>) : boolean;
                //write data to XML node
                    //create new child node
                        function tryCreateNewChild(const childNodeIdentifierIn, childNodeDataTypeIn : string; out newChildNodeOut : TWrappedXMLNode) : boolean; overload;
                    //data type
                        procedure setDataType(const nodeTypeIn : string);
                    //boolean
                        procedure writeBoolean(const dataIdentifierIn : string; const boolValueIn : boolean);
                    //integer
                        procedure writeInteger(const dataIdentifierIn : string; const integerValueIn : integer);
                    //double
                        procedure writeDouble(const dataIdentifierIn : string; const doubleValueIn : double);
                    //string
                        procedure writeString(const dataIdentifierIn, stringValueIn : string);
                    //arrays
                        //integer
                            procedure writeIntegerArray(const dataIdentifierIn : string; integerArrayIn : TArray<integer>);
                        //double
                            procedure writeDoubleArray(const dataIdentifierIn : string; doubleArrayIn : TArray<double>);
                        //string
                            procedure writeStringArray(const dataIdentifierIn : string; stringArrayIn : TArray<string>);
        end;

implementation

    uses
        VCL.Controls; //VCL.controls initialisation section initialises the MSXML library

    const
        //general strings
            ARRAY_ELEMENT_DELIMITER : string = ';';
            NODE_DATA_TYPE_STRING   : string = 'NodeDataType';
            VALUE_TYPE_STRING       : string = 'ValueType';
        //value type strings
            VT_NONE         : string = 'none';
            VT_BOOL         : string = 'boolean';
            VT_INT          : string = 'integer';
            VT_INT_ARRAY    : string = 'integer_array';
            VT_DOUBLE       : string = 'double';
            VT_DOUBLE_ARRAY : string = 'double_array';
            VT_STRING       : string = 'string';
            VT_STRING_ARRAY : string = 'string_array';

    //private
        //child nodes
            //try get a child node
                function TWrappedXMLNode.tryGetChildNode(const childNodeIdentifierIn : string; out childNodeOut : TWrappedXMLNode) : boolean;
                    var
                        childNode       : IXMLNode;
                    begin
                        if NOT( Assigned( wrappedXMLDataNode ) ) then
                            exit( False );

                        childNode := wrappedXMLDataNode.ChildNodes.FindNode( childNodeIdentifierIn );

                        if NOT( Assigned(childNode) ) then
                            exit( False );

                        childNodeOut.setXMLNode( childNode );

                        result := True;
                    end;

            //create new child node
                function TWrappedXMLNode.tryCreateNewChild(const childNodeIdentifierIn : string; out newChildNodeOut : TWrappedXMLNode) : boolean;
                    var
                        childNodeAlreadyExists  : boolean;
                        childNode,
                        newChildNode            : IXMLNode;
                    begin
                        //check if the data identifier is already used
                            childNode := wrappedXMLDataNode.ChildNodes.FindNode( childNodeIdentifierIn );

                            childNodeAlreadyExists := Assigned( childNode );

                            if ( childNodeAlreadyExists ) then
                                begin
                                    newChildNodeOut.setXMLNode( nil );
                                    exit( False );
                                end;

                        //create the new child now
                            newChildNode := wrappedXMLDataNode.AddChild( childNodeIdentifierIn );

                            newChildNodeOut.setXMLNode( newChildNode );

                        result := True;
                    end;

        //read from nodes
            //read value from node
                function TWrappedXMLNode.tryReadValue(const dataIdentifierIn, valueTypeIn : string; out valueOut : string) : boolean;
                    var
                        childDataNode : TWrappedXMLNode;
                    begin
                        //initialise value
                            valueOut := '';

                        //check if the parent node is assigned
                            if NOT( Assigned(wrappedXMLDataNode) ) then
                                exit( False );

                        //get the child data node
                            if NOT( tryGetChildNode( dataIdentifierIn, childDataNode ) ) then
                                exit( False );

                        //check the child value type is correct
                            if NOT( childDataNode.wrappedXMLDataNode.Attributes[ VALUE_TYPE_STRING ] = valueTypeIn ) then
                                exit( False );

                        valueOut := trim( childDataNode.wrappedXMLDataNode.Text );

                        result := True;
                    end;

            //read array
                function TWrappedXMLNode.tryReadArray(const dataIdentifierIn, arrayTypeIn : string; out valuesArrayOut : TArray<string>) : boolean;
                    var
                        readSuccessful, dataIsArray : boolean;
                        readDataValue               : string;
                    begin
                        readSuccessful := tryReadValue( dataIdentifierIn, arrayTypeIn, readDataValue );

                        if ( NOT( readSuccessful ) OR ( readDataValue = '' ) ) then
                            begin
                                SetLength( valuesArrayOut, 0 );
                                exit( False );
                            end;

                        dataIsArray := Pos( ARRAY_ELEMENT_DELIMITER, readDataValue ) > 1;

                        if NOT( dataIsArray ) then
                            begin
                                SetLength( valuesArrayOut, 1 );
                                valuesArrayOut[0] := readDataValue;
                                exit( True );
                            end;

                        valuesArrayOut := SplitString( readDataValue, ARRAY_ELEMENT_DELIMITER );

                        result := True;
                    end;

        //write to nodes
            //write value to node
                procedure TWrappedXMLNode.writeValue(const dataIdentifierIn, valueTypeIn, valueIn : string);
                    var
                        childDataNode : TWrappedXMLNode;
                    begin
                        //check if the XML node is assigned ( != nil )
                            if NOT( Assigned( wrappedXMLDataNode ) ) then
                                exit();

                        //create a child data node
                            if NOT( tryCreateNewChild( dataIdentifierIn, childDataNode ) ) then
                                exit();

                        //write data to node
                            childDataNode.wrappedXMLDataNode.Attributes[ VALUE_TYPE_STRING ] := valueTypeIn;
                            childDataNode.wrappedXMLDataNode.Text := Trim( valueIn );
                    end;

            //write array to node
                procedure TWrappedXMLNode.writeArray(const dataIdentifierIn, arrayTypeIn : string; valuesArrayIn : TArray<string>);
                    var
                        concatenatedValuesArray : string;
                    begin
                        concatenatedValuesArray := string.Join( ARRAY_ELEMENT_DELIMITER, valuesArrayIn );

                        writeValue( dataIdentifierIn, arrayTypeIn, concatenatedValuesArray );
                    end;

    //public
        //set the XML node
            procedure TWrappedXMLNode.setXMLNode(const newXMLNodeIn : IXMLNode);
                begin
                    wrappedXMLDataNode := newXMLNodeIn;
                end;

        //read data from XML node
            //try get a parent node's child node
                function TWrappedXMLNode.tryGetChildNode(const childNodeIdentifierIn, childNodeDataTypeIn : string; out childNodeOut : TWrappedXMLNode) : boolean;
                    begin
                        if NOT( tryGetChildNode( childNodeIdentifierIn, childNodeOut ) ) then
                            exit( False );

                        result := childNodeOut.isDataType( childNodeDataTypeIn );
                    end;

            //data type
                function TWrappedXMLNode.isDataType(const nodeDataTypeIn : string) : boolean;
                    var
                        localNodeDataType : string;
                    begin
                        localNodeDataType := getDataType();

                        result := ( localNodeDataType = nodeDataTypeIn );
                    end;

                function TWrappedXMLNode.getDataType() : string;
                    begin
                        if NOT( Assigned( wrappedXMLDataNode ) ) then
                            exit( VT_NONE );

                        result := wrappedXMLDataNode.Attributes[ NODE_DATA_TYPE_STRING ];
                    end;

            //boolean
                function TWrappedXMLNode.tryReadBoolean(const dataIdentifierIn : string; out boolValueOut : boolean; const defaultValueIn : boolean = False) : boolean;
                    var
                        readSuccessful, dataIsBool  : boolean;
                        readDataValue               : string;
                    begin
                        readSuccessful := tryReadValue( dataIdentifierIn, VT_BOOL, readDataValue );

                        dataIsBool := TryStrToBool( readDataValue, boolValueOut );

                        if NOT( readSuccessful AND dataIsBool ) then
                            begin
                                boolValueOut := defaultValueIn;
                                exit( False );
                            end;

                        result := True;
                    end;

            //integer
                function TWrappedXMLNode.tryReadInteger(const dataIdentifierIn : string; out integerValueOut : integer; const defaultValueIn : integer = 0) : boolean;
                    var
                        readSuccessful, dataIsInteger   : boolean;
                        readStringValue                 : string;
                    begin
                        readSuccessful := tryReadValue( dataIdentifierIn, VT_INT, readStringValue );

                        dataIsInteger := TryStrToInt( readStringValue, integerValueOut );

                        if NOT( readSuccessful AND dataIsInteger ) then
                            begin
                                integerValueOut := defaultValueIn;
                                exit( False );
                            end;

                        result := True;
                    end;

            //double
                function TWrappedXMLNode.tryReadDouble(const dataIdentifierIn : string; out doubleValueOut : double; const defaultValueIn : double = 0) : boolean;
                    var
                        readSuccessful, dataIsDouble    : boolean;
                        readStringValue                 : string;
                    begin
                        readSuccessful := tryReadValue( dataIdentifierIn, VT_DOUBLE, readStringValue );

                        dataIsDouble := TryStrToFloat( readStringValue, doubleValueOut );

                        if NOT( readSuccessful AND dataIsDouble ) then
                            begin
                                doubleValueOut := defaultValueIn;
                                exit( False );
                            end;

                        result := True;
                    end;

            //string
                function TWrappedXMLNode.tryReadString(const dataIdentifierIn : string; out stringValueOut : string; const defaultValueIn : string = '') : boolean;
                    var
                        readSuccessful : boolean;
                    begin
                        readSuccessful := tryReadValue( dataIdentifierIn, VT_STRING, stringValueOut );

                        if NOT( readSuccessful ) then
                            begin
                                stringValueOut := defaultValueIn;
                                exit( False );
                            end;

                        result := True;
                    end;

            //arrays
                //integer
                    function TWrappedXMLNode.TryReadIntegerArray(const dataIdentifierIn : string; out integerArrayOut : TArray<integer>) : boolean;
                        var
                            readSuccessful, IsIntegerArray  : boolean;
                            readStringArray                 : TArray<string>;
                        begin
                            readSuccessful := tryReadArray( dataIdentifierIn, VT_INT_ARRAY, readStringArray );

                            IsIntegerArray := tryConvertStringArrayToIntArray( readStringArray, integerArrayOut );

                            if NOT( readSuccessful AND IsIntegerArray ) then
                                begin
                                    SetLength( integerArrayOut, 0 );
                                    exit( False );
                                end;

                            result := True;
                        end;

                //double
                    function TWrappedXMLNode.TryReadDoubleArray(const dataIdentifierIn : string; out doubleArrayOut : TArray<double>) : boolean;
                        var
                            readSuccessful, IsDoubleArray   : boolean;
                            readStringArray                 : TArray<string>;
                        begin
                            readSuccessful := tryReadArray( dataIdentifierIn, VT_DOUBLE_ARRAY, readStringArray );

                            IsDoubleArray := tryConvertStringArrayToDoubleArray( readStringArray, doubleArrayOut );

                            if NOT( readSuccessful AND IsDoubleArray ) then
                                begin
                                    SetLength( doubleArrayOut, 0 );
                                    exit( False );
                                end;

                            result := True;
                        end;

                //string
                    function TWrappedXMLNode.TryReadStringArray(const dataIdentifierIn : string; out stringArrayOut : TArray<string>) : boolean;
                        var
                            readSuccessful : boolean;
                        begin
                            readSuccessful := tryReadArray( dataIdentifierIn, VT_STRING_ARRAY, stringArrayOut );

                            if NOT( readSuccessful ) then
                                begin
                                    SetLength( stringArrayOut, 0 );
                                    exit( False );
                                end;

                            result := True;
                        end;

        //write data to XML node
            //create new child node
                function TWrappedXMLNode.tryCreateNewChild(const childNodeIdentifierIn, childNodeDataTypeIn : string; out newChildNodeOut : TWrappedXMLNode) : boolean;
                    begin
                        if NOT( tryCreateNewChild( childNodeIdentifierIn, newChildNodeOut ) ) then
                            exit( False );

                        newChildNodeOut.setDataType( childNodeDataTypeIn );

                        result := True;
                    end;

            //data type
                procedure TWrappedXMLNode.setDataType(const nodeTypeIn : string);
                    begin
                        if NOT( Assigned( wrappedXMLDataNode ) ) then
                            exit();

                        wrappedXMLDataNode.Attributes[ NODE_DATA_TYPE_STRING ] := nodeTypeIn;
                    end;

            //boolean
                procedure TWrappedXMLNode.writeBoolean(const dataIdentifierIn : string; const boolValueIn : boolean);
                    var
                        boolStr : string;
                    begin
                        boolStr := BoolToStr( boolValueIn, True );

                        writeValue( dataIdentifierIn, VT_BOOL, boolStr );
                    end;

            //integer
                procedure TWrappedXMLNode.writeInteger(const dataIdentifierIn : string; const integerValueIn : integer);
                    var
                        intStr : string;
                    begin
                        intStr := IntToStr( integerValueIn );

                        writeValue( dataIdentifierIn, VT_INT, intStr );
                    end;

            //double
                procedure TWrappedXMLNode.writeDouble(const dataIdentifierIn : string; const doubleValueIn : double);
                    var
                        doubleStr : string;
                    begin
                        doubleStr := FloatToStr( doubleValueIn );

                        writeValue( dataIdentifierIn, VT_DOUBLE, doubleStr );
                    end;

            //string
                procedure TWrappedXMLNode.writeString(const dataIdentifierIn, stringValueIn : string);
                    begin
                        writeValue( dataIdentifierIn, VT_STRING, stringValueIn );
                    end;

            //arrays
                //integer
                    procedure TWrappedXMLNode.writeIntegerArray(const dataIdentifierIn : string; integerArrayIn : TArray<integer>);
                        var
                            integerStringArray : TArray<string>;
                        begin
                            integerStringArray := convertIntArrayToStringArray( integerArrayIn );

                            writeArray( dataIdentifierIn, VT_INT_ARRAY, integerStringArray );
                        end;

                //double
                    procedure TWrappedXMLNode.writeDoubleArray(const dataIdentifierIn : string; doubleArrayIn : TArray<double>);
                        var
                            doubleStringArray : TArray<string>;
                        begin
                            doubleStringArray := convertDoubleArrayToStringArray( doubleArrayIn );

                            writeArray( dataIdentifierIn, VT_DOUBLE_ARRAY, doubleStringArray );
                        end;

                //string
                    procedure TWrappedXMLNode.writeStringArray(const dataIdentifierIn : string; stringArrayIn : TArray<string>);
                        begin
                            writeArray( dataIdentifierIn, VT_STRING_ARRAY, stringArrayIn );
                        end;

end.
