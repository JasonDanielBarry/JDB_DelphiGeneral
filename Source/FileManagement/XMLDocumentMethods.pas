unit XMLDocumentMethods;

interface

    uses
        system.SysUtils, system.Classes, system.Generics.Collections, system.StrUtils,
        Xml.XMLDoc, Xml.XMLIntf, Xml.xmldom,
        ArrayConversionMethods
        ;

    //read data from XML node
        //try get a parent node's child node
            function tryGetXMLChildNode(const parentNodeIn : IXMLNode; const childNodeIdentifierIn : string; out childNodeOut : IXMLNode) : boolean; overload;
            function tryGetXMLChildNode(const parentNodeIn : IXMLNode; const childNodeIdentifierIn, childNodeDataTypeIn : string; out childNodeOut : IXMLNode) : boolean; overload;

        //data type
            function XMLNodeIsDataType(const XMLNodeIn : IXMLNode; const nodeDataTypeIn : string) : boolean;
            function getXMLNodeDataType(const XMLNodeIn : IXMLNode) : string;

        //boolean
            function tryReadBooleanFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out boolValueOut : boolean; const defaultValueIn : boolean = False) : boolean;

        //integer
            function tryReadIntegerFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out integerValueOut : integer; const defaultValueIn : integer = 0) : boolean;

        //double
            function tryReadDoubleFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out doubleValueOut : double; const defaultValueIn : double = 0) : boolean;

        //string
            function tryReadStringFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out stringValueOut : string; const defaultValueIn : string = '') : boolean;

        //arrays
            //integer
                function TryReadIntegerArrayFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out integerArrayOut : TArray<integer>) : boolean;

            //double
                function TryReadDoubleArrayFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out doubleArrayOut : TArray<double>) : boolean;

            //string
                function TryReadStringArrayFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out stringArrayOut : TArray<string>) : boolean;

    //write data to XML node
        //create new child node
            function tryCreateNewXMLChildNode(const parentNodeIn : IXMLNode; const childNodeIdentifierIn : string; out newChildNodeOut : IXMLNode) : boolean; overload;
            function tryCreateNewXMLChildNode(const parentNodeIn : IXMLNode; const childNodeIdentifierIn, childNodeDataTypeIn : string; out newChildNodeOut : IXMLNode) : boolean; overload;

        //data type
            procedure setXMLNodeDataType(var XMLNodeInOut : IXMLNode; const nodeTypeIn : string);

        //boolean
            procedure writeBooleanToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; boolValueIn : boolean);

        //integer
            procedure writeIntegerToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; integerValueIn : integer);

        //double
            procedure writeDoubleToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; doubleValueIn : double);

        //string
            procedure writeStringToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn, stringValueIn : string);

        //arrays
            //integer
                procedure writeIntegerArrayToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; integerArrayIn : TArray<integer>);

            //double
                procedure writeDoubleArrayToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; doubleArrayIn : TArray<double>);

            //string
                procedure writeStringArrayToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; stringArrayIn : TArray<string>);

implementation

    const
        //general strings
            ARRAY_ELEMENT_DELIMITER : string = ';';
            NODE_DATA_TYPE_STRING   : string = 'NodeDataType';
            VALUE_TYPE_STRING       : string = 'ValueType';
        //data type strings
            DT_NONE         : string = 'none';
            DT_BOOL         : string = 'boolean';
            DT_INT          : string = 'integer';
            DT_INT_ARRAY    : string = 'integer_array';
            DT_DOUBLE       : string = 'double';
            DT_DOUBLE_ARRAY : string = 'double_array';
            DT_STRING       : string = 'string';
            DT_STRING_ARRAY : string = 'string_array';

    //read data from XML node
        //try get a parent node's child node
            function tryGetXMLChildNode(const parentNodeIn : IXMLNode; const childNodeIdentifierIn : string; out childNodeOut : IXMLNode) : boolean;
                begin
                    if NOT( Assigned( parentNodeIn ) ) then
                        exit( False );

                    childNodeOut := parentNodeIn.ChildNodes.FindNode( childNodeIdentifierIn );

                    if NOT( Assigned(childNodeOut) ) then
                        exit( False );

                    result := True;
                end;

            function tryGetXMLChildNode(const parentNodeIn : IXMLNode; const childNodeIdentifierIn, childNodeDataTypeIn : string; out childNodeOut : IXMLNode) : boolean;
                begin
                    if NOT( tryGetXMLChildNode( parentNodeIn, childNodeIdentifierIn, childNodeOut ) ) then
                        exit( False );

                    result := XMLNodeIsDataType( childNodeOut, childNodeDataTypeIn );
                end;

        function tryReadValueFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn, valueTypeIn : string; out valueOut : string) : boolean;
            var
                childDataNode : IXMLNode;
            begin
                //initialise value
                    valueOut := '';

                //check if the parent node is assigned
                    if NOT( Assigned(XMLNodeIn) ) then
                        exit( False );

                //get the child data node
                    if NOT( tryGetXMLChildNode( XMLNodeIn, dataIdentifierIn, childDataNode ) ) then
                        exit( False );

                //check the child data type is correct
                    if NOT( childDataNode.Attributes[ VALUE_TYPE_STRING ] = valueTypeIn ) then
                        exit( False );

                valueOut := trim( childDataNode.Text );

                result := True;
            end;

        //data type
            function XMLNodeIsDataType(const XMLNodeIn : IXMLNode; const nodeDataTypeIn : string) : boolean;
                begin
                    result := ( getXMLNodeDataType( XMLNodeIn ) = nodeDataTypeIn );
                end;

            function getXMLNodeDataType(const XMLNodeIn : IXMLNode) : string;
                begin
                    if NOT( Assigned( XMLNodeIn ) ) then
                        exit( DT_NONE );

                    result := XMLNodeIn.Attributes[ NODE_DATA_TYPE_STRING ];
                end;

        //boolean
            function tryReadBooleanFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out boolValueOut : boolean; const defaultValueIn : boolean = False) : boolean;
                var
                    readSuccessful, dataIsBool  : boolean;
                    readDataValue               : string;
                begin
                    readSuccessful := tryReadValueFromXMLNode( XMLNodeIn, dataIdentifierIn, DT_BOOL, readDataValue );

                    dataIsBool := TryStrToBool( readDataValue, boolValueOut );

                    if NOT( readSuccessful AND dataIsBool ) then
                        begin
                            boolValueOut := defaultValueIn;
                            exit( False );
                        end;

                    result := True;
                end;

        //integer
            function tryReadIntegerFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out integerValueOut : integer; const defaultValueIn : integer = 0) : boolean;
                var
                    readSuccessful, dataIsInteger   : boolean;
                    readStringValue                 : string;
                begin
                    readSuccessful := tryReadValueFromXMLNode( XMLNodeIn, dataIdentifierIn, DT_INT, readStringValue );

                    dataIsInteger := TryStrToInt( readStringValue, integerValueOut );

                    if NOT( readSuccessful AND dataIsInteger ) then
                        begin
                            integerValueOut := defaultValueIn;
                            exit( False );
                        end;

                    result := True;
                end;

        //double
            function tryReadDoubleFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out doubleValueOut : double; const defaultValueIn : double = 0) : boolean;
                var
                    readSuccessful, dataIsDouble    : boolean;
                    readStringValue                 : string;
                begin
                    readSuccessful := tryReadValueFromXMLNode( XMLNodeIn, dataIdentifierIn, DT_DOUBLE, readStringValue );

                    dataIsDouble := TryStrToFloat( readStringValue, doubleValueOut );

                    if NOT( readSuccessful AND dataIsDouble ) then
                        begin
                            doubleValueOut := defaultValueIn;
                            exit( False );
                        end;

                    result := True;
                end;

        //string
            function tryReadStringFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out stringValueOut : string; const defaultValueIn : string = '') : boolean;
                var
                    readSuccessful : boolean;
                begin
                    readSuccessful := tryReadValueFromXMLNode( XMLNodeIn, dataIdentifierIn, DT_STRING, stringValueOut );

                    if NOT( readSuccessful ) then
                        begin
                            stringValueOut := defaultValueIn;
                            exit( False );
                        end;

                    result := True;
                end;

        //arrays
            function tryReadArrayFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn, arrayTypeIn : string; out stringArrayOut : TArray<string>) : boolean;
                var
                    readSuccessful, dataIsArray : boolean;
                    readDataValue               : string;
                begin
                    readSuccessful := tryReadValueFromXMLNode( XMLNodeIn, dataIdentifierIn, arrayTypeIn, readDataValue );

                    if ( NOT( readSuccessful ) OR ( readDataValue = '' ) ) then
                        begin
                            SetLength( stringArrayOut, 0 );
                            exit( False );
                        end;

                    dataIsArray := Pos( ARRAY_ELEMENT_DELIMITER, readDataValue ) > 1;

                    if NOT( dataIsArray ) then
                        begin
                            SetLength( stringArrayOut, 1 );
                            stringArrayOut[0] := readDataValue;
                            exit(True);
                        end;

                    stringArrayOut := SplitString( readDataValue, ARRAY_ELEMENT_DELIMITER );

                    result := True;
                end;

            //integer
                function TryReadIntegerArrayFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out integerArrayOut : TArray<integer>) : boolean;
                    var
                        readSuccessful, IsIntegerArray  : boolean;
                        readStringArray                 : TArray<string>;
                    begin
                        readSuccessful := tryReadArrayFromXMLNode( XMLNodeIn, dataIdentifierIn, DT_INT_ARRAY, readStringArray );

                        IsIntegerArray := tryConvertStringArrayToIntArray( readStringArray, integerArrayOut );

                        if NOT( readSuccessful AND IsIntegerArray ) then
                            begin
                                SetLength( integerArrayOut, 0 );
                                exit( False );
                            end;

                        result := True;
                    end;

            //double
                function TryReadDoubleArrayFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out doubleArrayOut : TArray<double>) : boolean;
                    var
                        readSuccessful, IsDoubleArray   : boolean;
                        readStringArray                 : TArray<string>;
                    begin
                        readSuccessful := tryReadArrayFromXMLNode( XMLNodeIn, dataIdentifierIn, DT_DOUBLE_ARRAY, readStringArray );

                        IsDoubleArray := tryConvertStringArrayToDoubleArray( readStringArray, doubleArrayOut );

                        if NOT( readSuccessful AND IsDoubleArray ) then
                            begin
                                SetLength( doubleArrayOut, 0 );
                                exit( False );
                            end;

                        result := True;
                    end;

            //string
                function TryReadStringArrayFromXMLNode(const XMLNodeIn : IXMLNode; const dataIdentifierIn : string; out stringArrayOut : TArray<string>) : boolean;
                    var
                        readSuccessful : boolean;
                    begin
                        readSuccessful := tryReadArrayFromXMLNode( XMLNodeIn, dataIdentifierIn, DT_STRING_ARRAY, stringArrayOut );

                        if NOT( readSuccessful ) then
                            begin
                                SetLength( stringArrayOut, 0 );
                                exit( False );
                            end;

                        result := True;
                    end;

    //write data to XML node
        //create new child node
            function tryCreateNewXMLChildNode(const parentNodeIn : IXMLNode; const childNodeIdentifierIn : string; out newChildNodeOut : IXMLNode) : boolean;
                var
                    childNodeAlreadyExists  : boolean;
                    childNode               : IXMLNode;
                begin
                    //check if the data identifier is already used
                        childNode := parentNodeIn.ChildNodes.FindNode( childNodeIdentifierIn );

                        childNodeAlreadyExists := Assigned( childNode );

                        if ( childNodeAlreadyExists ) then
                            begin
                                newChildNodeOut := nil;
                                exit( False );
                            end;

                    //create the new child now
                        newChildNodeOut := parentNodeIn.AddChild( childNodeIdentifierIn );

                    result := True;
                end;

            function tryCreateNewXMLChildNode(const parentNodeIn : IXMLNode; const childNodeIdentifierIn, childNodeDataTypeIn : string; out newChildNodeOut : IXMLNode) : boolean;
                begin
                    if NOT( tryCreateNewXMLChildNode( parentNodeIn, childNodeIdentifierIn, newChildNodeOut ) ) then
                        exit( False );

                    setXMLNodeDataType( newChildNodeOut, childNodeDataTypeIn );

                    result := True;
                end;

        procedure writeValueToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn, valueTypeIn, valueIn : string);
            var
                childDataNode : IXMLNode;
            begin
                //check if the XML node is assigned ( != nil )
                    if NOT( Assigned(XMLNodeInOut) ) then
                        exit();

                //create a child data node
                    if NOT( tryCreateNewXMLChildNode( XMLNodeInOut, dataIdentifierIn, childDataNode ) ) then
                        exit();

                //write data to node
                    childDataNode.Attributes[ VALUE_TYPE_STRING ] := valueTypeIn;
                    childDataNode.Text := Trim( valueIn );
            end;

        //data type
            procedure setXMLNodeDataType(var XMLNodeInOut : IXMLNode; const nodeTypeIn : string);
                begin
                    if NOT( Assigned( XMLNodeInOut ) ) then
                        exit();

                    XMLNodeInOut.Attributes[ NODE_DATA_TYPE_STRING ] := nodeTypeIn;
                end;

        //boolean
            procedure writeBooleanToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; boolValueIn : boolean);
                var
                    boolStr : string;
                begin
                    boolStr := BoolToStr( boolValueIn, True );

                    writeValueToXMLNode( XMLNodeInOut, dataIdentifierIn, DT_BOOL, boolStr );
                end;

        //integer
            procedure writeIntegerToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; integerValueIn : integer);
                var
                    intStr : string;
                begin
                    intStr := IntToStr( integerValueIn );

                    writeValueToXMLNode( XMLNodeInOut, dataIdentifierIn, DT_INT, intStr )
                end;

        //double
            procedure writeDoubleToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; doubleValueIn : double);
                var
                    doubleStr : string;
                begin
                    doubleStr := FloatToStr( doubleValueIn );

                    writeValueToXMLNode( XMLNodeInOut, dataIdentifierIn, DT_DOUBLE, doubleStr )
                end;

        //string
            procedure writeStringToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn, stringValueIn : string);
                begin
                    writeValueToXMLNode( XMLNodeInOut, dataIdentifierIn, DT_STRING, stringValueIn );
                end;

        //arrays
            procedure writeArrayToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn, arrayTypeIn : string; stringArrayIn : TArray<string>);
                var
                    concatenatedArray : string;
                begin
                    concatenatedArray := string.Join( ARRAY_ELEMENT_DELIMITER, stringArrayIn );

                    writeValueToXMLNode( XMLNodeInOut, dataIdentifierIn, arrayTypeIn, concatenatedArray );
                end;

            //integer
                procedure writeIntegerArrayToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; integerArrayIn : TArray<integer>);
                    var
                        stringArray : TArray<string>;
                    begin
                        stringArray := convertIntArrayToStringArray( integerArrayIn );

                        writeArrayToXMLNode( XMLNodeInOut, dataIdentifierIn, DT_INT_ARRAY, stringArray );
                    end;

            //double
                procedure writeDoubleArrayToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; doubleArrayIn : TArray<double>);
                    var
                        stringArray : TArray<string>;
                    begin
                        stringArray := convertDoubleArrayToStringArray( doubleArrayIn );

                        writeArrayToXMLNode( XMLNodeInOut, dataIdentifierIn, DT_DOUBLE_ARRAY, stringArray );
                    end;

            //string
                procedure writeStringArrayToXMLNode(var XMLNodeInOut : IXMLNode; const dataIdentifierIn : string; stringArrayIn : TArray<string>);
                    begin
                        writeArrayToXMLNode( XMLNodeInOut, dataIdentifierIn, DT_STRING_ARRAY, stringArrayIn );
                    end;

end.
