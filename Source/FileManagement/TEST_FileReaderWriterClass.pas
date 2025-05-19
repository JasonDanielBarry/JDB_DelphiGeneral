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
                    TEST_FILE_PATH : string = '..\FRWTestFile.xml';
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
                procedure testWriteData();

        end;

implementation

    uses
        system.Math,
        FileReaderWriterClass;

    procedure TTestFileReaderWriterClass.deleteTestFile();
        begin
            if (FileExists( TEST_FILE_PATH )) then
                DeleteFile( TEST_FILE_PATH );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteBool();
        var
            testBool        : boolean;
            fileReadWrite   : TFileReaderWriter;
        begin
            deleteTestFile();

            //save data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.writeBool( 'boolean1', True );
                fileReadWrite.writeBool( 'boolean2', False );

                fileReadWrite.saveFile();

                FreeAndNil( fileReadWrite );

            //load data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.loadFile();

                fileReadWrite.tryReadBool( 'boolean1', testBool );
                Assert.IsTrue( testBool = True );

                fileReadWrite.tryReadBool( 'boolean2', testBool );
                Assert.IsTrue( testBool = False );

                FreeAndNil( fileReadWrite );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteInteger();
        var
            testInteger     : integer;
            fileReadWrite   : TFileReaderWriter;
        begin
            deleteTestFile();

            //save data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.writeInteger( 'integer1', 2 );
                fileReadWrite.writeInteger( 'integer2', 8 );
                fileReadWrite.writeInteger( 'integer3', 32 );
                fileReadWrite.writeInteger( 'integer4', 128 );
                fileReadWrite.writeInteger( 'integer5', 512 );

                fileReadWrite.saveFile();

                FreeAndNil( fileReadWrite );

            //load data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.loadFile();

                fileReadWrite.tryReadInteger( 'integer1', testInteger );
                assert.AreEqual( testInteger, 2 );

                fileReadWrite.tryReadInteger( 'integer2', testInteger );
                assert.AreEqual( testInteger, 8 );

                fileReadWrite.tryReadInteger( 'integer3', testInteger );
                assert.AreEqual( testInteger, 32 );

                fileReadWrite.tryReadInteger( 'integer4', testInteger );
                assert.AreEqual( testInteger, 128 );

                fileReadWrite.tryReadInteger( 'integer5', testInteger );
                assert.AreEqual( testInteger, 512 );

                FreeAndNil( fileReadWrite );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteDouble();
        var
            testDouble      : double;
            fileReadWrite   : TFileReaderWriter;
        begin
            deleteTestFile();

            //save data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.writeDouble( 'double1', 123.456 );
                fileReadWrite.writeDouble( 'double2', 654.987 );
                fileReadWrite.writeDouble( 'double3', 741.852 );
                fileReadWrite.writeDouble( 'double4', 369.258 );
                fileReadWrite.writeDouble( 'double5', 159.753 );

                fileReadWrite.saveFile();

                FreeAndNil( fileReadWrite );

            //load data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.loadFile();

                fileReadWrite.tryReadDouble( 'double1', testDouble );
                assert.IsTrue( SameValue( testDouble, 123.456, 1e-3) );

                fileReadWrite.tryReadDouble( 'double2', testDouble );
                assert.IsTrue( SameValue( testDouble, 654.987, 1e-3) );

                fileReadWrite.tryReadDouble( 'double3', testDouble );
                assert.IsTrue( SameValue( testDouble, 741.852, 1e-3) );

                fileReadWrite.tryReadDouble( 'double4', testDouble );
                assert.IsTrue( SameValue( testDouble, 369.258, 1e-3) );

                fileReadWrite.tryReadDouble( 'double5', testDouble );
                assert.IsTrue( SameValue( testDouble, 159.753, 1e-3) );

                FreeAndNil( fileReadWrite );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteString();
        var
            testString      : string;
            fileReadWrite   : TFileReaderWriter;
        begin
            deleteTestFile();

            //save data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.writeString( 'string1', 'asdf' );
                fileReadWrite.writeString( 'string2', '!@#$%' );
                fileReadWrite.writeString( 'string3', 'Jason Daniel Barry' );
                fileReadWrite.writeString( 'string4', 'Youtube' );
                fileReadWrite.writeString( 'string5', '123.456' );

                fileReadWrite.saveFile();

                FreeAndNil( fileReadWrite );

            //load data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.loadFile();

                fileReadWrite.tryReadString( 'string1', testString );
                assert.AreEqual( testString, 'asdf' );

                fileReadWrite.tryReadString( 'string2', testString );
                assert.AreEqual( testString, '!@#$%' );

                fileReadWrite.tryReadString( 'string3', testString );
                assert.AreEqual( testString, 'Jason Daniel Barry' );

                fileReadWrite.tryReadString( 'string4', testString );
                assert.AreEqual( testString, 'Youtube' );

                fileReadWrite.tryReadString( 'string5', testString );
                assert.AreEqual( testString, '123.456' );

                FreeAndNil( fileReadWrite );
        end;

    procedure TTestFileReaderWriterClass.testReadWriteArrays();
        var
            i                                   : integer;
            integerArrayRead, integerArrayWrite : TArray<integer>;
            doubleArrayRead, doubleArrayWrite   : TArray<double>;
            stringArrayRead, stringArrayWrite   : TArray<string>;
            fileReadWrite                       : TFileReaderWriter;
        begin
            deleteTestFile();

            integerArrayWrite   := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
            doubleArrayWrite    := [1.1, 2.2, 456.987, 159.951, 45.98, 79.651, 1472.8523, 1234.0987];
            stringArrayWrite    := ['This', 'I$', '@ string', '123 array', 'to %$#', '159 test', 'reading', '@nd', 'WRITING'];

            //save data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.writeIntegerArray( 'IntegerArray', integerArrayWrite );
                fileReadWrite.writeDoubleArray( 'DoubleArray', doubleArrayWrite );
                fileReadWrite.writeStringArray( 'StringArray', stringArrayWrite );

                fileReadWrite.saveFile();

                FreeAndNil( fileReadWrite );

            //load data
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.loadFile();

                //integer
                    fileReadWrite.tryReadIntegerArray( 'IntegerArray', integerArrayRead );
                    assert.AreEqual<integer>( integerArrayRead, integerArrayWrite );

                //double
                    fileReadWrite.tryReadDoubleArray( 'DoubleArray', doubleArrayRead );
                    for i := 0 to ( length(doubleArrayRead) - 1 ) do
                        assert.IsTrue( SameValue( doubleArrayRead[i], doubleArrayWrite[i], 1e-3 ) );

                //string
                    fileReadWrite.tryReadStringArray( 'StringArray', stringArrayRead );
                    assert.AreEqual<string>( stringArrayRead, stringArrayWrite );

                FreeAndNil( fileReadWrite );
        end;

    procedure TTestFileReaderWriterClass.testReadGhostData();
        var
            testBool        : boolean;
            testInt         : integer;
            testDouble      : double;
            testString      : string;
            fileReadWrite   : TFileReaderWriter;
        begin
            deleteTestFile();

            //save a file
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                //boolean
                    fileReadWrite.writeBool( 'boolean1', True );
                    fileReadWrite.writeInteger( 'integer1', 2 );
                    fileReadWrite.writeDouble( 'double1', 123.456 );
                    fileReadWrite.writeString( 'string1', 'asdf' );

                fileReadWrite.saveFile();

                FreeAndNil( fileReadWrite );

            //load the file
                fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

                fileReadWrite.loadFile();

                //try read data that does not exist
                    fileReadWrite.tryReadBool( 'ghostBool', testBool, True );
                    assert.AreEqual( testBool, True );

                    fileReadWrite.tryReadInteger( 'ghostInt', testInt, 101 );
                    assert.AreEqual( testInt, 101 );

                    fileReadWrite.tryReadDouble( 'ghostDouble', testDouble, 159.789 );
                    assert.IsTrue( SameValue( testDouble, 159.789, 1e-3 ) );

                    fileReadWrite.tryReadString( 'ghostString', testString, 'asdf' );
                    assert.AreEqual( testString, 'asdf' );

                FreeAndNil( fileReadWrite );
        end;

    procedure TTestFileReaderWriterClass.testWriteData();
        var
            integerArray    : TArray<integer>;
            doubleArray     : TArray<double>;
            stringArray     : TArray<string>;
            fileReadWrite   : TFileReaderWriter;
        begin
            deleteTestFile();

            fileReadWrite := TFileReaderWriter.create( TEST_FILE_PATH );

            //boolean
                fileReadWrite.writeBool( 'boolean1', True );
                fileReadWrite.writeBool( 'boolean2', False );

            //integer
                fileReadWrite.writeInteger( 'integer1', 2 );
                fileReadWrite.writeInteger( 'integer2', 8 );
                fileReadWrite.writeInteger( 'integer3', 32 );
                fileReadWrite.writeInteger( 'integer4', 128 );
                fileReadWrite.writeInteger( 'integer5', 512 );

            //double
                fileReadWrite.writeDouble( 'double1', 123.456 );
                fileReadWrite.writeDouble( 'double2', 654.987 );
                fileReadWrite.writeDouble( 'double3', 741.852 );
                fileReadWrite.writeDouble( 'double4', 369.258 );
                fileReadWrite.writeDouble( 'double5', 159.753 );

            //string
                fileReadWrite.writeString( 'string1', 'asdf' );
                fileReadWrite.writeString( 'string2', '!@#$%' );
                fileReadWrite.writeString( 'string3', 'Jason Daniel Barry' );
                fileReadWrite.writeString( 'string4', 'Youtube' );
                fileReadWrite.writeString( 'string5', '123.456' );

            //array
                integerArray   := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
                doubleArray    := [1.1, 2.2, 456.987, 159.951, 45.98, 79.651, 1472.8523, 1234.0987];
                stringArray    := ['This', 'I$', '@ string', '123 array', 'to %$#', '159 test', 'reading', '@nd', 'WRITING'];

                fileReadWrite.writeIntegerArray( 'IntegerArray', integerArray );
                fileReadWrite.writeDoubleArray( 'DoubleArray', doubleArray );
                fileReadWrite.writeStringArray( 'StringArray', stringArray );

            fileReadWrite.saveFile();

            FreeAndNil( fileReadWrite );
        end;

end.
