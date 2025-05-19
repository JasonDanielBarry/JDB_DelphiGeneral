unit ArrayConversionMethods;

interface

    uses
        system.SysUtils;

    //from string array
        //string array to integer array
            function tryConvertStringArrayToIntArray(const stringArrayIn : TArray<string>; out intArrayOut : TArray<Integer>) : boolean;

        //string array to double array
            function tryConvertStringArrayToDoubleArray(const stringArrayIn : TArray<string>; out doubleArrayOut : TArray<double>) : boolean;

    //to string array
        //integer array to string array
            function convertIntArrayToStringArray(const intArrayIn : TArray<integer>) : TArray<string>;

        //double array to string array
            function convertDoubleArrayToStringArray(const doubleArrayIn : TArray<double>) : TArray<string>;
        

implementation

    //from string array
        //string array to integer array
            function tryConvertStringArrayToIntArray(const stringArrayIn : TArray<string>; out intArrayOut : TArray<Integer>) : boolean;
                var
                    valueIsInt          : boolean;
                    i, arrLen, intValue : integer;
                begin
                    arrLen := length( stringArrayIn );

                    if (arrLen < 1) then
                        begin
                            SetLength( intArrayOut, 0 );
                            exit( False );
                        end;

                    SetLength( intArrayOut, arrLen );

                    for i := 0 to ( arrLen - 1 ) do
                        begin
                            valueIsInt := TryStrToInt( stringArrayIn[i], intValue );

                            if NOT(valueIsInt) then
                                begin
                                    SetLength( intArrayOut, 0 );
                                    exit( False );
                                end;

                            intArrayOut[i] := intValue;
                        end;

                    result := True;
                end;

        //string array to double array
            function tryConvertStringArrayToDoubleArray(const stringArrayIn : TArray<string>; out doubleArrayOut : TArray<double>) : boolean;
                var
                    valueIsDouble   : boolean;
                    i, arrLen       : integer;
                    doubleValue     : double;
                begin
                    arrLen := length( stringArrayIn );

                    if (arrLen < 1) then
                        begin
                            SetLength( doubleArrayOut, 0 );
                            exit( False );
                        end;

                    SetLength( doubleArrayOut, arrLen );

                    for i := 0 to ( arrLen - 1 ) do
                        begin
                            valueIsDouble := TryStrToFloat( stringArrayIn[i], doubleValue );

                            if NOT(valueIsDouble) then
                                begin
                                    SetLength( doubleArrayOut, 0 );
                                    exit( False );
                                end;

                            doubleArrayOut[i] := doubleValue;
                        end;

                    result := True;
                end;

    //to string array
        //integer array to string array
            function convertIntArrayToStringArray(const intArrayIn : TArray<integer>) : TArray<string>;
                var
                    i, arrLen       : integer;
                    stringArrayOut  : Tarray<string>;
                begin
                    arrLen := Length( intArrayIn );

                    SetLength( stringArrayOut, arrLen );

                    for i := 0 to ( arrLen - 1 ) do
                        stringArrayOut[i] := IntToStr( intArrayIn[i] );

                    result := stringArrayOut;
                end;

        //double array to string array
            function convertDoubleArrayToStringArray(const doubleArrayIn : TArray<double>) : TArray<string>;
                var
                    i, arrLen       : integer;
                    stringArrayOut  : Tarray<string>;
                begin
                    arrLen := Length( doubleArrayIn );

                    SetLength( stringArrayOut, arrLen );

                    for i := 0 to ( arrLen - 1 ) do
                        stringArrayOut[i] := FloatToStr( doubleArrayIn[i] );

                    result := stringArrayOut;
                end;

end.
