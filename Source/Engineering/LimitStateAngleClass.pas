unit LimitStateAngleClass;

interface

    uses
        system.SysUtils, system.Math,
        LimitStateMaterialClass;

    type
        TLimitStateAngle = class(TLimitStateMaterial)
            strict private
                limitStateMaterial  : TLimitStateMaterial;
                function cautiousEstimateTangent() : double;
                procedure updateMaterial();
            public
                constructor create();
                destructor destroy(); override;
                function cautiousEstimate() : double; override;
                function designValue() : double; override;
                procedure setValues(const averageValueIn, variationCoefficientIn, downgradeFactorIn, partialFactorIn : double); override;
                procedure copyOther(const otherMaterialIn: TLimitStateMaterial); override;
        end;

implementation

    //private
        function TLimitStateAngle.cautiousEstimateTangent() : double;
            var
                tanCautiousEstimate : double;
            begin
                //calculate the cautious estimate tangent
                    updateMaterial();

                    tanCautiousEstimate := limitStateMaterial.cautiousEstimate();

                result := tanCautiousEstimate;
            end;

        procedure TLimitStateAngle.updateMaterial();
            var
                averageValueRadians,
                tanAverageValue     : double;
            begin
                //convert average value from angle into tangent value
                    averageValueRadians := DegToRad( averageValue );

                    tanAverageValue := Tan( averageValueRadians );

                limitStateMaterial.setValues(   tanAverageValue,
                                                self.variationCoefficient,
                                                self.downgradeFactor,
                                                Self.partialFactor          );
            end;

    //public
        constructor TLimitStateAngle.create();
            begin
                inherited create();

                limitStateMaterial := TLimitStateMaterial.create();
            end;

        destructor TLimitStateAngle.destroy();
            begin
                FreeAndNil(limitStateMaterial);

                inherited destroy();
            end;

        function TLimitStateAngle.cautiousEstimate() : double;
            var
                cautiousEstimateRadians,
                cautiousEstimateDegrees,
                tanCautiousEstimate     : double;
            begin
                //get the caustion estimate tangent
                    tanCautiousEstimate := cautiousEstimateTangent();

                //convert back to degrees
                    cautiousEstimateRadians := ArcTan( tanCautiousEstimate );

                    cautiousEstimateDegrees := RadToDeg( cautiousEstimateRadians );

                result := cautiousEstimateDegrees;
            end;

        function TLimitStateAngle.designValue() : double;
            var
                designValueRadians,
                designValueDegrees,
                tanDesignValue      : double;
            begin
                updateMaterial();

                tanDesignValue := limitStateMaterial.designValue();

                designValueRadians := arctan(tanDesignValue);

                designValueDegrees := RadToDeg(designValueRadians);

                result := designValueDegrees;
            end;

        procedure TLimitStateAngle.setValues(const averageValueIn, variationCoefficientIn, downgradeFactorIn, partialFactorIn : double);
            begin
                inherited setValues(averageValueIn, variationCoefficientIn, downgradeFactorIn, partialFactorIn);

                updateMaterial();
            end;

        procedure TLimitStateAngle.copyOther(const otherMaterialIn: TLimitStateMaterial);
            begin
                inherited copyOther(otherMaterialIn);
            end;

end.
