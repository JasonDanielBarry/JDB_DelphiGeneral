unit LimitStateMaterialClass;

interface

    uses
        system.SysUtils, system.Math,
        Xml.XMLIntf,
        XMLDocumentMethods
        ;

    type
        TLimitStateMaterial = class
            var
                averageValue,
                variationCoefficient,
                downgradeFactor,
                partialFactor       : double;
            constructor create();
            destructor destroy(); override;
            function cautiousEstimate() : double; virtual;
            function designValue() : double; virtual;
            procedure setValues(const averageValueIn, variationCoefficientIn, downgradeFactorIn, partialFactorIn : double); virtual;
            procedure copyOther(const otherMaterialIn: TLimitStateMaterial); virtual;
            procedure useAverageValue();
            procedure useLimitStateValue(const variationCoefficientIn, downgradeFactorIn, partialFactorIn : double);
            function tryReadFromXMLNode(const XMLNodeIn : IXMLNode; const identifierIn : string) : boolean;
            procedure writeToXMLNode(var XMLNodeInOut : IXMLNode; const identifierIn : string);
        end;

implementation

    constructor TLimitStateMaterial.create();
        begin
            inherited create();
        end;

    destructor TLimitStateMaterial.destroy();
        begin
            inherited destroy();
        end;

    function TLimitStateMaterial.cautiousEstimate() : double;
        var
            av, vc, df : double;
        begin
            av := averageValue;
            vc := variationCoefficient;
            df := downgradeFactor;

            result := av * (1 - vc * df);
        end;

    function TLimitStateMaterial.designValue() : double;
        begin
            result := cautiousEstimate() / partialFactor;
        end;

    procedure TLimitStateMaterial.setValues(const averageValueIn, variationCoefficientIn, downgradeFactorIn, partialFactorIn : double);
        begin
            averageValue          := max(0, averageValueIn);
            variationCoefficient  := max(0, variationCoefficientIn);
            downgradeFactor       := max(0, downgradeFactorIn);
            partialFactor         := max(1, partialFactorIn);
        end;

    procedure TLimitStateMaterial.copyOther(const otherMaterialIn: TLimitStateMaterial);
        begin
            setValues(  otherMaterialIn.averageValue,
                        otherMaterialIn.variationCoefficient,
                        otherMaterialIn.downgradeFactor,
                        otherMaterialIn.partialFactor        );
        end;

    procedure TLimitStateMaterial.useAverageValue();
        begin
            setValues( self.averageValue, 0, 0, 1 );
        end;

    procedure TLimitStateMaterial.useLimitStateValue(const variationCoefficientIn, downgradeFactorIn, partialFactorIn : double);
        begin
            setValues( self.averageValue, variationCoefficientIn, downgradeFactorIn, partialFactorIn );
        end;

    const
        AVERAGE_VALUE           : string = 'AverageValue';
        VARIATION_COEFFICIENT   : string = 'VariationCoefficient';
        DOWNGRADE_FACTOR        : string = 'DowngradeFactor';
        PARTIAL_FACTOR          : string = 'PartialFactor';
        DT_LIMIT_STATE_MATERIAL : string = 'TLimitStateMaterial';

    function TLimitStateMaterial.tryReadFromXMLNode(const XMLNodeIn : IXMLNode; const identifierIn : string) : boolean;
        var
            successfulRead : boolean;
            limitStateNode : IXMLNode;
        begin
            if NOT( tryGetXMLChildNode(XMLNodeIn, identifierIn, DT_LIMIT_STATE_MATERIAL, limitStateNode ) ) then
                exit( False );

            successfulRead := tryReadDoubleFromXMLNode( limitStateNode, AVERAGE_VALUE, self.averageValue );
            successfulRead := tryReadDoubleFromXMLNode( limitStateNode, VARIATION_COEFFICIENT, self.variationCoefficient ) AND successfulRead;
            successfulRead := tryReadDoubleFromXMLNode( limitStateNode, DOWNGRADE_FACTOR,      self.downgradeFactor      ) AND successfulRead;
            successfulRead := tryReadDoubleFromXMLNode( limitStateNode, PARTIAL_FACTOR,        self.partialFactor, 1     ) AND successfulRead;

            result := successfulRead;
        end;

    procedure TLimitStateMaterial.writeToXMLNode(var XMLNodeInOut : IXMLNode; const identifierIn : string);
        var
            limitStateNode : IXMLNode;
        begin
            if NOT( tryCreateNewXMLChildNode( XMLNodeInOut, identifierIn, DT_LIMIT_STATE_MATERIAL, limitStateNode ) ) then
                exit();

            writeDoubleToXMLNode( limitStateNode, AVERAGE_VALUE,          averageValue          );
            writeDoubleToXMLNode( limitStateNode, VARIATION_COEFFICIENT,  variationCoefficient  );
            writeDoubleToXMLNode( limitStateNode, DOWNGRADE_FACTOR,       downgradeFactor       );
            writeDoubleToXMLNode( limitStateNode, PARTIAL_FACTOR,         partialFactor         );
        end;

end.
