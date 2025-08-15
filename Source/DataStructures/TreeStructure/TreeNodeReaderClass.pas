unit TreeNodeReaderClass;

interface

    uses
        system.SysUtils, System.StrUtils,
        ArrayConversionMethods,
        TreeStructureTypes,
        TreeNodeBaseClass,
        TreeNodeWriterClass
        ;

    type
        TTreeNodeReader = class( TTreeNodeWriter )
            private
                //read value from node
                    function tryReadvalue(const valueIdentifierIn, expectedValueTypeIn : string; out valueStringOut : string) : boolean;
                //read array
                    function tryReadArray(const arrayIdentifierIn, arrayTypeIn : string; out valuesArrayOut : TArray<string>) : boolean;
            public
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
        end;

implementation

    //private
        //read value from node
            function TTreeNodeReader.tryReadvalue(const valueIdentifierIn, expectedValueTypeIn : string; out valueStringOut : string) : boolean;
                var
                    childValueNodeExists,
                    valueTypeIsCorrect      : boolean;
                    nodeValueString,
                    nodeValueType           : string;
                    childValueNode          : TTreeNodeBase;
                begin
                    result := False;

                    //try to get the node holding the value
                        childValueNodeExists := tryGetChildNode( valueIdentifierIn, childValueNode );

                        if NOT( childValueNodeExists ) then
                            exit( False );

                    //get the value and its type from the node
                        TTreeNodeReader( childValueNode ).readStoredValueAndType( nodeValueString, nodeValueType );

                    //check that the value type matches that expected
                        valueTypeIsCorrect := ( nodeValueType = expectedValueTypeIn );

                        if NOT( valueTypeIsCorrect ) then
                            exit( False );

                    //return the value string
                        valueStringOut := nodeValueString;

                    result := True;
                end;

        //read array
            function TTreeNodeReader.tryReadArray(const arrayIdentifierIn, arrayTypeIn : string; out valuesArrayOut : TArray<string>) : boolean;
                var
                    readSuccessful, dataIsArray : boolean;
                    readDataValue               : string;
                begin
                    readSuccessful := tryReadValue( arrayIdentifierIn, arrayTypeIn, readDataValue );

                    if ( NOT( readSuccessful ) OR ( readDataValue = '' ) ) then
                        begin
                            SetLength( valuesArrayOut, 0 );
                            exit( False );
                        end;

                    dataIsArray := readDataValue.Contains( ARRAY_ELEMENT_DELIMITER );

                    if NOT( dataIsArray ) then
                        begin
                            SetLength( valuesArrayOut, 1 );
                            valuesArrayOut[0] := readDataValue;
                            exit( True );
                        end;

                    valuesArrayOut := SplitString( readDataValue, ARRAY_ELEMENT_DELIMITER );

                    result := True;
                end;

    //public
        //boolean
            function TTreeNodeReader.tryReadBoolean(const dataIdentifierIn : string; out boolValueOut : boolean; const defaultValueIn : boolean = False) : boolean;
                var
                    readSuccessful, dataIsBool  : boolean;
                    readDataValue               : string;
                begin
                    readSuccessful := tryReadValue( dataIdentifierIn, NVT_BOOL, readDataValue );

                    dataIsBool := TryStrToBool( readDataValue, boolValueOut );

                    if NOT( readSuccessful AND dataIsBool ) then
                        begin
                            boolValueOut := defaultValueIn;
                            exit( False );
                        end;

                    result := True;
                end;

        //integer
            function TTreeNodeReader.tryReadInteger(const dataIdentifierIn : string; out integerValueOut : integer; const defaultValueIn : integer = 0) : boolean;
                var
                    readSuccessful, dataIsInteger   : boolean;
                    readStringValue                 : string;
                begin
                    readSuccessful := tryReadValue( dataIdentifierIn, NVT_INT, readStringValue );

                    dataIsInteger := TryStrToInt( readStringValue, integerValueOut );

                    if NOT( readSuccessful AND dataIsInteger ) then
                        begin
                            integerValueOut := defaultValueIn;
                            exit( False );
                        end;

                    result := True;
                end;

        //double
            function TTreeNodeReader.tryReadDouble(const dataIdentifierIn : string; out doubleValueOut : double; const defaultValueIn : double = 0) : boolean;
                var
                    readSuccessful, dataIsDouble    : boolean;
                    readStringValue                 : string;
                begin
                    readSuccessful := tryReadValue( dataIdentifierIn, NVT_DOUBLE, readStringValue );

                    dataIsDouble := TryStrToFloat( readStringValue, doubleValueOut );

                    if NOT( readSuccessful AND dataIsDouble ) then
                        begin
                            doubleValueOut := defaultValueIn;
                            exit( False );
                        end;

                    result := True;
                end;

        //string
            function TTreeNodeReader.tryReadString(const dataIdentifierIn : string; out stringValueOut : string; const defaultValueIn : string = '') : boolean;
                var
                    readSuccessful : boolean;
                begin
                    readSuccessful := tryReadValue( dataIdentifierIn, NVT_STRING, stringValueOut );

                    if NOT( readSuccessful ) then
                        begin
                            stringValueOut := defaultValueIn;
                            exit( False );
                        end;

                    result := True;
                end;

        //arrays
            //integer
                function TTreeNodeReader.TryReadIntegerArray(const dataIdentifierIn : string; out integerArrayOut : TArray<integer>) : boolean;
                    var
                        readSuccessful, IsIntegerArray  : boolean;
                        readStringArray                 : TArray<string>;
                    begin
                        readSuccessful := tryReadArray( dataIdentifierIn, NVT_INT_ARRAY, readStringArray );

                        IsIntegerArray := tryConvertStringArrayToIntArray( readStringArray, integerArrayOut );

                        if NOT( readSuccessful AND IsIntegerArray ) then
                            begin
                                SetLength( integerArrayOut, 0 );
                                exit( False );
                            end;

                        result := True;
                    end;

            //double
                function TTreeNodeReader.TryReadDoubleArray(const dataIdentifierIn : string; out doubleArrayOut : TArray<double>) : boolean;
                    var
                        readSuccessful, IsDoubleArray   : boolean;
                        readStringArray                 : TArray<string>;
                    begin
                        readSuccessful := tryReadArray( dataIdentifierIn, NVT_DOUBLE_ARRAY, readStringArray );

                        IsDoubleArray := tryConvertStringArrayToDoubleArray( readStringArray, doubleArrayOut );

                        if NOT( readSuccessful AND IsDoubleArray ) then
                            begin
                                SetLength( doubleArrayOut, 0 );
                                exit( False );
                            end;

                        result := True;
                    end;

            //string
                function TTreeNodeReader.TryReadStringArray(const dataIdentifierIn : string; out stringArrayOut : TArray<string>) : boolean;
                    var
                        readSuccessful : boolean;
                    begin
                        readSuccessful := tryReadArray( dataIdentifierIn, NVT_STRING_ARRAY, stringArrayOut );

                        if NOT( readSuccessful ) then
                            begin
                                SetLength( stringArrayOut, 0 );
                                exit( False );
                            end;

                        result := True;
                    end;

end.
