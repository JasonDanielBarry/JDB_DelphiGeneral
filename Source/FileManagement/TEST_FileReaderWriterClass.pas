unit TEST_FileReaderWriterClass;

interface

    uses
        system.SysUtils,
        DUnitX.TestFramework;

    type
        [TestFixture]
        TTestFileReaderWriterClass = class
            private
                const
                    TEST_FILE_PATH : string = '..\XMLFileReadWriteTest.xml';
                procedure deleteTestFile();
            public
                [Test]
                procedure testReadWriteBool();
                [Test]
                procedure testReadWriteInteger();
                [Test]
                procedure testReadWriteDouble();
                [Test]
                procedure testReadWriteString();
                [Test]
                procedure testReadWriteArrays();
                [Test]
                procedure testReadGhostData();
                [Test]
                procedure testComplexType();
        end;

implementation

    uses
        system.Math,
        XMLNodeWrapper,
        XMLFileReaderWriter;

    type
        TComplexTypeRecord = record
            private
                const
                    TYPE_STRING : string = 'TComplexTypeRecord';
                    BOOL_VAL    : string = 'boolVal';
                    INT_VAL     : string = 'intVal';
                    DOUBLE_VAL  : string = 'doubleVal';
                    STRING_VAL  : string = 'stringVal';
                    ARR_INT     : string = 'arrInt';
                    ARR_DOUBLE  : string = 'arrDouble';
                    ARR_STRING  : string = 'arrString';
                var
                    boolVal     : boolean;
                    intVal      : integer;
                    doubleVal   : double;
                    stringVal   : string;
                    arrInt      : TArray<integer>;
                    arrDouble   : TArray<double>;
                    arrString   : TArray<string>;
            public
                procedure initialiseValues( boolValIn       : boolean;
                                            intValIn        : integer;
                                            doubleValIn     : double;
                                            stringValIn     : string;
                                            arrIntIn        : TArray<integer>;
                                            arrDoubleIn     : TArray<double>;
                                            arrStringIn     : TArray<string>    );
                function isEqual(const otherComplexRecordIn : TComplexTypeRecord) : boolean;
                function tryReadFromXML(const xmlNodeIn : TWrappedXMLNode; const identifierIn : string) : boolean;
                procedure writeToXML(const xmlNodeIn : TWrappedXMLNode; const identifierIn : string);
        end;

    procedure TComplexTypeRecord.initialiseValues(  boolValIn       : boolean;
                                                    intValIn        : integer;
                                                    doubleValIn     : double;
                                                    stringValIn     : string;
                                                    arrIntIn        : TArray<integer>;
                                                    arrDoubleIn     : TArray<double>;
                                                    arrStringIn     : TArray<string>    );
        begin
            boolVal     := boolValIn;
            intVal      := intValIn;
            doubleVal   := doubleValIn;
            stringVal   := stringValIn;
            arrInt      := arrIntIn;
            arrDouble   := arrDoubleIn;
            arrString   := arrStringIn;
        end;

    function TComplexTypeRecord.isEqual(const otherComplexRecordIn : TComplexTypeRecord) : boolean;
        var
            areEqual    : boolean;
            i           : integer;
        begin
            areEqual := True;

            areEqual := areEqual AND (self.boolVal = otherComplexRecordIn.boolVal);
            areEqual := areEqual AND (self.intVal = otherComplexRecordIn.intVal);
            areEqual := areEqual AND SameValue(self.doubleVal, otherComplexRecordIn.doubleVal, 1e-3);
            areEqual := areEqual AND (self.stringVal = otherComplexRecordIn.stringVal);

            for i := 0 to (length(self.arrInt) - 1) do
                areEqual := areEqual AND (self.arrInt[i] = otherComplexRecordIn.arrInt[i]);

            for i := 0 to (length(self.arrDouble) - 1) do
                areEqual := areEqual AND SameValue(self.arrDouble[i], otherComplexRecordIn.arrDouble[i], 1e-3);

            for i := 0 to (length(self.arrString) - 1) do
                areEqual := areEqual AND (self.arrString[i] = otherComplexRecordIn.arrString[i]);

            result := areEqual;
        end;

    function TComplexTypeRecord.tryReadFromXML(const xmlNodeIn : TWrappedXMLNode; const identifierIn : string) : boolean;
        var
            readSuccussful  : boolean;
            complexTypeNode,
            arraysNode      : TWrappedXMLNode;
        begin
            if NOT( xmlNodeIn.tryGetChildNode( identifierIn, TYPE_STRING, complexTypeNode ) ) then
                exit( False );

            readSuccussful := True;

            readSuccussful := complexTypeNode.tryReadBoolean(   BOOL_VAL,       boolVal     ) AND readSuccussful;
            readSuccussful := complexTypeNode.tryReadInteger(   INT_VAL,        intVal      ) AND readSuccussful;
            readSuccussful := complexTypeNode.tryReadDouble(    DOUBLE_VAL,     doubleVal   ) AND readSuccussful;
            readSuccussful := complexTypeNode.tryReadString(    STRING_VAL,     stringVal   ) AND readSuccussful;

            readSuccussful := complexTypeNode.tryGetChildNode( 'ArrayData', 'ARRAYS', arraysNode ) AND readSuccussful;

            readSuccussful := arraysNode.TryReadIntegerArray(   ARR_INT,        arrInt      ) AND readSuccussful;
            readSuccussful := arraysNode.TryReadDoubleArray(    ARR_DOUBLE,     arrDouble   ) AND readSuccussful;
            readSuccussful := arraysNode.TryReadStringArray(    ARR_STRING,     arrString   ) AND readSuccussful;

            result := readSuccussful;
        end;

    procedure TComplexTypeRecord.writeToXML(const xmlNodeIn : TWrappedXMLNode; const identifierIn : string);
        var
            complexTypeNode,
            arraysNode      : TWrappedXMLNode;
        begin
            if NOT( xmlNodeIn.tryCreateNewChild( identifierIn, TYPE_STRING, complexTypeNode ) ) then
                exit();

            complexTypeNode.writeBoolean(   BOOL_VAL,       boolVal     );
            complexTypeNode.writeInteger(   INT_VAL,        intVal      );
            complexTypeNode.writeDouble(    DOUBLE_VAL,     doubleVal   );
            complexTypeNode.writeString(    STRING_VAL,     stringVal   );

            if NOT( complexTypeNode.tryCreateNewChild( 'ArrayData', 'ARRAYS', arraysNode ) ) then
                exit();

            arraysNode.writeIntegerArray(   ARR_INT,        arrInt      );
            arraysNode.writeDoubleArray(    ARR_DOUBLE,     arrDouble   );
            arraysNode.writeStringArray(    ARR_STRING,     arrString   );
        end;

    procedure TTestFileReaderWriterClass.deleteTestFile();
        begin
            if (FileExists( TEST_FILE_PATH )) then
                DeleteFile( TEST_FILE_PATH );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteBool();
        var
            testBool    : boolean;
            XMLFile     : TXMLFileReaderWriter;
        begin
            deleteTestFile();

            //save data
                XMLFile.initialiseXMLDocument();

                XMLFile.RootNode.writeBoolean( 'boolean1', True );
                XMLFile.RootNode.writeBoolean( 'boolean2', False );

                XMLFile.saveFile(TEST_FILE_PATH);

            //load data
                XMLFile.loadFile(TEST_FILE_PATH);

                XMLFile.RootNode.tryReadBoolean( 'boolean1', testBool );
                Assert.IsTrue( testBool = True );

                XMLFile.RootNode.tryReadBoolean( 'boolean2', testBool );
                Assert.IsTrue( testBool = False );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteInteger();
        var
            testInteger : integer;
            XMLFile     : TXMLFileReaderWriter;
        begin
            deleteTestFile();

            //save data
                XMLFile.initialiseXMLDocument();

                XMLFile.RootNode.writeInteger( 'integer1', 2 );
                XMLFile.RootNode.writeInteger( 'integer2', 8 );
                XMLFile.RootNode.writeInteger( 'integer3', 32 );
                XMLFile.RootNode.writeInteger( 'integer4', 128 );
                XMLFile.RootNode.writeInteger( 'integer5', 512 );

                XMLFile.saveFile(TEST_FILE_PATH);

            //load data
                XMLFile.loadFile(TEST_FILE_PATH);

                XMLFile.RootNode.tryReadInteger( 'integer1', testInteger );
                assert.AreEqual( testInteger, 2 );

                XMLFile.RootNode.tryReadInteger( 'integer2', testInteger );
                assert.AreEqual( testInteger, 8 );

                XMLFile.RootNode.tryReadInteger( 'integer3', testInteger );
                assert.AreEqual( testInteger, 32 );

                XMLFile.RootNode.tryReadInteger( 'integer4', testInteger );
                assert.AreEqual( testInteger, 128 );

                XMLFile.RootNode.tryReadInteger( 'integer5', testInteger );
                assert.AreEqual( testInteger, 512 );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteDouble();
        var
            testDouble  : double;
            XMLFile     : TXMLFileReaderWriter;
        begin
            deleteTestFile();

            //save data
                XMLFile.initialiseXMLDocument();

                XMLFile.RootNode.writeDouble( 'double1', 123.456 );
                XMLFile.RootNode.writeDouble( 'double2', 654.987 );
                XMLFile.RootNode.writeDouble( 'double3', 741.852 );
                XMLFile.RootNode.writeDouble( 'double4', 369.258 );
                XMLFile.RootNode.writeDouble( 'double5', 159.753 );

                XMLFile.saveFile(TEST_FILE_PATH);

            //load data
                XMLFile.loadFile(TEST_FILE_PATH);

                XMLFile.RootNode.tryReadDouble( 'double1', testDouble );
                assert.IsTrue( SameValue( testDouble, 123.456, 1e-3) );

                XMLFile.RootNode.tryReadDouble( 'double2', testDouble );
                assert.IsTrue( SameValue( testDouble, 654.987, 1e-3) );

                XMLFile.RootNode.tryReadDouble( 'double3', testDouble );
                assert.IsTrue( SameValue( testDouble, 741.852, 1e-3) );

                XMLFile.RootNode.tryReadDouble( 'double4', testDouble );
                assert.IsTrue( SameValue( testDouble, 369.258, 1e-3) );

                XMLFile.RootNode.tryReadDouble( 'double5', testDouble );
                assert.IsTrue( SameValue( testDouble, 159.753, 1e-3) );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteString();
        var
            testString  : string;
            XMLFile     : TXMLFileReaderWriter;
        begin
            deleteTestFile();

            //save data
                XMLFile.initialiseXMLDocument();

                XMLFile.RootNode.writeString( 'string1', 'asdf' );
                XMLFile.RootNode.writeString( 'string2', '!@#$%' );
                XMLFile.RootNode.writeString( 'string3', 'Jason Daniel Barry' );
                XMLFile.RootNode.writeString( 'string4', 'Youtube' );
                XMLFile.RootNode.writeString( 'string5', '123.456' );

                XMLFile.saveFile( TEST_FILE_PATH );

            //load data
                XMLFile.loadFile( TEST_FILE_PATH );

                XMLFile.RootNode.tryReadString( 'string1', testString );
                assert.AreEqual( testString, 'asdf' );

                XMLFile.RootNode.tryReadString( 'string2', testString );
                assert.AreEqual( testString, '!@#$%' );

                XMLFile.RootNode.tryReadString( 'string3', testString );
                assert.AreEqual( testString, 'Jason Daniel Barry' );

                XMLFile.RootNode.tryReadString( 'string4', testString );
                assert.AreEqual( testString, 'Youtube' );

                XMLFile.RootNode.tryReadString( 'string5', testString );
                assert.AreEqual( testString, '123.456' );
        end;

    procedure TestDoubleArraysAreEqual(const arr1In, arr2In : TArray<double>);
        var
            i : integer;
        begin
            for i := 0 to ( length(arr1In) - 1 ) do
                assert.IsTrue( SameValue( arr1In[i], arr2In[i], 1e-3 ) );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteArrays();
        var
            i                                   : integer;
            integerArrayRead, integerArrayWrite : TArray<integer>;
            doubleArrayRead, doubleArrayWrite   : TArray<double>;
            stringArrayRead, stringArrayWrite   : TArray<string>;
            XMLFile                             : TXMLFileReaderWriter;
        begin
            deleteTestFile();

            integerArrayWrite   := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
            doubleArrayWrite    := [1.1, 2.2, 456.987, 159.951, 45.98, 79.651, 1472.8523, 1234.0987];
            stringArrayWrite    := ['This', 'I$', '@ string', '123 array', 'to %$#', '159 test', 'reading', '@nd', 'WRITING'];

            //save data
                XMLFile.initialiseXMLDocument();

                XMLFile.RootNode.writeIntegerArray( 'IntegerArray', integerArrayWrite );
                XMLFile.RootNode.writeDoubleArray( 'DoubleArray', doubleArrayWrite );
                XMLFile.RootNode.writeStringArray( 'StringArray', stringArrayWrite );

                XMLFile.saveFile(TEST_FILE_PATH);

            //load data
                XMLFile.loadFile(TEST_FILE_PATH);

                //integer
                    XMLFile.RootNode.tryReadIntegerArray( 'IntegerArray', integerArrayRead );
                    assert.AreEqual<integer>( integerArrayRead, integerArrayWrite );

                //double
                    XMLFile.RootNode.tryReadDoubleArray( 'DoubleArray', doubleArrayRead );
                    TestDoubleArraysAreEqual( doubleArrayRead, doubleArrayWrite );

                //string
                    XMLFile.RootNode.tryReadStringArray( 'StringArray', stringArrayRead );
                    assert.AreEqual<string>( stringArrayRead, stringArrayWrite );
        end;

    procedure TTestFileReaderWriterClass.testReadGhostData();
        var
            testBool        : boolean;
            testInt         : integer;
            testDouble      : double;
            testString      : string;
            XMLFile   : TXMLFileReaderWriter;
        begin
            deleteTestFile();

            //save a file
                XMLFile.initialiseXMLDocument();

                //boolean
                    XMLFile.RootNode.writeBoolean( 'boolean1', True );
                    XMLFile.RootNode.writeInteger( 'integer1', 2 );
                    XMLFile.RootNode.writeDouble( 'double1', 123.456 );
                    XMLFile.RootNode.writeString( 'string1', 'asdf' );

                XMLFile.saveFile(TEST_FILE_PATH);

            //load the file
                //try read data that does not exist
                    XMLFile.RootNode.tryReadBoolean( 'ghostBool', testBool, True );
                    assert.AreEqual( testBool, True );

                    XMLFile.RootNode.tryReadInteger( 'ghostInt', testInt, 101 );
                    assert.AreEqual( testInt, 101 );

                    XMLFile.RootNode.tryReadDouble( 'ghostDouble', testDouble, 159.789 );
                    assert.IsTrue( SameValue( testDouble, 159.789, 1e-3 ) );

                    XMLFile.RootNode.tryReadString( 'ghostString', testString, 'asdf' );
                    assert.AreEqual( testString, 'asdf' );
        end;

    procedure TTestFileReaderWriterClass.testComplexType();
        const
            RECORD_IDENTIFIER : string = 'ComplexTypeData';
        var
            complexRecordsAreEqual  : boolean;
            readComplexType,
            writeComplexType        : TComplexTypeRecord;
            XMLFile                 : TXMLFileReaderWriter;
        begin
            //populate complex records with equal values
                readComplexType.initialiseValues( True, 1, 3.5, 'Jason Barry', [1, 2, 3], [1.1, 2.2, 3.3], ['Jason', 'Daniel', 'Barry'] );
                writeComplexType.initialiseValues( True, 1, 3.5, 'Jason Barry', [1, 2, 3], [1.1, 2.2, 3.3], ['Jason', 'Daniel', 'Barry'] );

            //save to XML file
                XMLFile.initialiseXMLDocument();

                writeComplexType.writeToXML( XMLFile.RootNode, RECORD_IDENTIFIER );

                XMLFile.saveFile( TEST_FILE_PATH );

            //reset the file
                XMLFile.initialiseXMLDocument();

            //load from XML file
                XMLFile.loadFile( TEST_FILE_PATH );

                readComplexType.tryReadFromXML( XMLFile.RootNode, RECORD_IDENTIFIER );

            //test for equality of read and write records
                complexRecordsAreEqual := readComplexType.isEqual( writeComplexType );

                assert.IsTrue( complexRecordsAreEqual );
        end;

end.
