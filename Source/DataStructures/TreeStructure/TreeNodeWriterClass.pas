unit TreeNodeWriterClass;

interface

    uses
        system.SysUtils,
        ArrayConversionMethods,
        TreeStructureTypes,
        TreeNodeBaseClass;

    type
        TTreeNodeWriter = class( TTreeNodeBase )
            private
                //write value to node
                    procedure writeValue(const valueIdentifierIn, valueTypeIn, valueStringIn : string);
                //write array to node
                    procedure writeArray(const arrayIdentifierIn, arrayTypeIn : string; valuesArrayIn : TArray<string>);
            public
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

    //private
        //write value to node
            procedure TTreeNodeWriter.writeValue(const valueIdentifierIn, valueTypeIn, valueStringIn : string);
                var
                    childNodeAlreadyExists  : boolean;
                    newChildNode            : TTreeNodeBase;
                begin
                    //NOTE: the value is saved using the following steps
                        //1. A child node of self is created and stored in the map using valueIdentifierIn as the key
                        //2. valueTypeIn and valueStringIn are then stored in the child node

                    //step 1
                        //check for child node existence
                            childNodeAlreadyExists := tryCreateNewChildNode( valueIdentifierIn, newChildNode );

                            if ( childNodeAlreadyExists ) then
                                exit();

                    //step 2
                        //write the data to the child node
                            TTreeNodeWriter( newChildNode ).writeToStoredValueAndType( valueStringIn, valueTypeIn );
                end;

        //write array to node
            procedure TTreeNodeWriter.writeArray(const arrayIdentifierIn, arrayTypeIn : string; valuesArrayIn : TArray<string>);
                var
                    concatenatedValuesArray : string;
                begin
                    //concatenate the string array into a single string
                        concatenatedValuesArray := string.Join( ARRAY_ELEMENT_DELIMITER, valuesArrayIn );

                    //single string can now be stored
                        writeValue( arrayIdentifierIn, arrayTypeIn, concatenatedValuesArray );
                end;

    //public
        //boolean
            procedure TTreeNodeWriter.writeBoolean(const dataIdentifierIn : string; const boolValueIn : boolean);
                var
                    boolStr : string;
                begin
                    boolStr := boolValueIn.ToString( True );

                    writeValue( dataIdentifierIn, NVT_BOOL, boolStr );
                end;

        //integer
            procedure TTreeNodeWriter.writeInteger(const dataIdentifierIn : string; const integerValueIn : integer);
                var
                    integerStr : string;
                begin
                    integerStr := integerValueIn.ToString();

                    writeValue( dataIdentifierIn, NVT_INT, integerStr );
                end;

        //double
            procedure TTreeNodeWriter.writeDouble(const dataIdentifierIn : string; const doubleValueIn : double);
                var
                    doubleStr : string;
                begin
                    doubleStr := doubleValueIn.ToString();

                    writeValue( dataIdentifierIn, NVT_DOUBLE, doubleStr );
                end;

        //string
            procedure TTreeNodeWriter.writeString(const dataIdentifierIn, stringValueIn : string);
                begin
                    writeValue( dataIdentifierIn, NVT_STRING, stringValueIn );
                end;

        //arrays
            //integer
                procedure TTreeNodeWriter.writeIntegerArray(const dataIdentifierIn : string; integerArrayIn : TArray<integer>);
                    var
                        integerStringArray : TArray<string>;
                    begin
                        integerStringArray := convertIntArrayToStringArray( integerArrayIn );

                        writeArray( dataIdentifierIn, NVT_INT_ARRAY, integerStringArray );
                    end;

            //double
                procedure TTreeNodeWriter.writeDoubleArray(const dataIdentifierIn : string; doubleArrayIn : TArray<double>);
                    var
                        doubleStringArray : TArray<string>;
                    begin
                        doubleStringArray := convertDoubleArrayToStringArray( doubleArrayIn );

                        writeArray( dataIdentifierIn, NVT_DOUBLE_ARRAY, doubleStringArray );
                    end;

            //string
                procedure TTreeNodeWriter.writeStringArray(const dataIdentifierIn : string; stringArrayIn : TArray<string>);
                    begin
                        writeArray( dataIdentifierIn, NVT_STRING_ARRAY, stringArrayIn );
                    end;
end.
