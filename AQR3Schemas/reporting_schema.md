```mermaid
erDiagram
    Adjustment {
        nvarchar CountryCode PK
        varchar ComplianceId PK
        nvarchar DeductionAssessmentMethod PK
        nvarchar AdjustmentType
        nvarchar AdjustmentSource
        decimal MaxRatioUncertainty
    }
    Adjustment }o--o{ ComplianceAssessmentMethod : "CountryCode + ComplianceId + DeductionAssessmentMethod"
    Adjustment }o--o{ Model : "CountryCode + ComplianceId + DeductionAssessmentMethod"

    AssessmentRegime {
        varchar CountryCode PK
        int ReportingYear PK
        varchar DataAggregationProcessId PK
        varchar AssessmentRegimeId PK
        varchar ZoneId
        nvarchar ZoneCode
        decimal ZoneArea
        varchar ZoneCategory
        nvarchar ZoneType
        varchar ZoneName
        int AirPollutantCode
        nvarchar ProtectionTarget
        nvarchar ObjectiveType
        nvarchar AssessmentThresholdExceedance
        int PostponementYear
        int FixedSPOReduction
        int ZoneResidentPopulationYear
        int ZoneResidentPopulation
        int ClassificationYear
        varchar ClassificationReport
    }
    AssessmentRegime ||--o{ ComplianceAssessmentMethod : "CountryCode + ReportingYear + AssessmentRegimeId + DataAggregationProcessId"

    Authority {
        nvarchar CountryCode PK
        nvarchar AuthorityInstanceId PK
        int Object PK
        nvarchar PersonEmail PK
        nvarchar OrganisationName
        nvarchar OrganisationURL
        nvarchar OrganisationAddress
        nvarchar PersonName
    }
    ComplianceAssessmentMethod {
        varchar CountryCode PK
        int ReportingYear PK
        varchar AssessmentRegimeId PK
        nvarchar AssessmentMethodId PK
        varchar AttainmentId PK
        int AirPollutantCode
        nvarchar DataAggregationProcessId
        nvarchar AssessmentType
        varchar AssessmentMethod
        int HotSpot
        varchar IsExceedance
        decimal AirPollutionLevel
        decimal AirPollutionLevelAdjusted
        decimal AbsoluteUncertaintyLimit
        decimal RelativeUncertaintyLimit
        decimal MaxRatioUncertainty
        char CorrectionFactor
        varchar ComplianceId
        nvarchar SamplingPointRepresentativenessAreaId
        nvarchar PreliminaryReason
    }
    ComplianceAssessmentMethod ||--o{ PlanScenario : "via CompliancePlanLink (CountryCode + PlanId + ScenarioId)"
    ComplianceAssessmentMethod ||--o{ SamplingPoint_SRA : "CountryCode + AssessmentMethodId + SamplingPointRepresentativenessAreaId"

    CompliancePlanLink {
        varchar CountryCode PK
        varchar ComplianceId PK
        nvarchar PlanId PK
        nvarchar SourceAppId PK
        nvarchar ScenarioId PK
    }
    CompliancePlanLink ||--o{ PlanScenario : "CountryCode + PlanId + ScenarioId"

    Measure {
        nvarchar CountryCode PK
        nvarchar MeasureId PK
        datetime ReportingTime PK
        nvarchar MeasureGroupId
        nvarchar MeasureCode
        nvarchar MeasureName
        nvarchar MeasureClassification
        nvarchar MeasureType
        nvarchar SourceSector
        nvarchar SpatialScale
        date ImplementationBegin
        date ImplementationEnd
        bigint Cost
        date FullEffectDate
        varchar MeasureStatus
        int ReasonIfMeasureNotUsed
    }
    MeasurementResults {
        varchar CountryCode PK
        varchar AssessmentMethodId PK
        int AirPollutantCode PK
        datetime Start PK
        datetime End PK
        decimal Value
        varchar Unit
        varchar ObservationFrequency
        int Validity
        int Verification
        decimal DataCapture
        datetime ResultTime
    }
    MeasurementResults ||--o{ ModellingResults : "CountryCode + AssessmentMethodId + AirPollutantCode"

    Model {
        varchar CountryCode PK
        nvarchar AssessmentMethodId PK
        int AirPollutantCode PK
        varchar DataAggregationProcessId PK
        nvarchar ResultEncoding
        nvarchar ModelApplication
        nvarchar ModelReport
        nvarchar DataQualityReport
        decimal MQI
    }
    Model ||--o{ ComplianceAssessmentMethod : "CountryCode + AssessmentMethodId + AirPollutantCode + DataAggregationProcessId"
    Model ||--o{ ModellingResults : "CountryCode + AssessmentMethodId + AirPollutantCode + DataAggregationProcessId"
    Model ||--o{ PlanScenario : "CountryCode + AssessmentMethodId + AirPollutantCode + DataAggregationProcessId"

    ModellingResults {
        varchar CountryCode PK
        varchar AssessmentMethodId PK
        int AirPollutantCode PK
        datetime Start PK
        varchar DataAggregationProcessId PK
        float X PK
        float Y PK
        decimal Value
        varchar Unit
        int Validity
        datetime ResultTime
    }
    ModellingResults ||--o{ ComplianceAssessmentMethod : "CountryCode + AssessmentMethodId + AirPollutantCode + DataAggregationProcessId"
    ModellingResults ||--o{ MeasurementResults : "CountryCode + AssessmentMethodId + AirPollutantCode"
    ModellingResults ||--o{ Model : "CountryCode + AssessmentMethodId + AirPollutantCode + DataAggregationProcessId"
    ModellingResults ||--o{ PlanScenario : "CountryCode + AssessmentMethodId + AirPollutantCode + DataAggregationProcessId"

    PlanScenario {
        nvarchar CountryCode PK
        nvarchar ScenarioId PK
        nvarchar PlanId PK
        varchar DataAggregationProcessId
        varchar ScenarioCategory
        int ScenarioYear
        float ScenarioAirPollutionLevel
        int AssessmentMethodId
        nvarchar AuthorityOrganisation
        nvarchar AuthorityWebsite
        varchar AuthorityLevel
        nvarchar SupportingDocumentation
    }
    PlanScenario ||--o{ ComplianceAssessmentMethod : "via CompliancePlanLink (CountryCode + PlanId + ScenarioId)"
    PlanScenario ||--o{ SourceApportionment : "via CompliancePlanLink (CountryCode + PlanId + ScenarioId)"
    PlanScenario ||--o{ Measure : "via ScenarioMeasure (CountryCode + PlanId + ScenarioId)"

    SamplingPoint {
        varchar CountryCode PK
        nvarchar AssessmentMethodId PK
        nvarchar ProcessId PK
        datetime2 ProcessActivityBegin PK
        nvarchar SamplingPointRef
        int AirPollutantCode
        nvarchar AirQualityStationType
        int SuperSite
        numeric Latitude
        numeric Longitude
        datetime2 ProcessActivityEnd
    }
    SamplingPoint_SRA {
        varchar CountryCode PK
        nvarchar SamplingPointRepresentativenessAreaId PK
        float X PK
        float Y PK
        int SpatialResolution
        varchar AssessmentMethodId
    }
    SamplingPoint_SRA ||--o{ ComplianceAssessmentMethod : "CountryCode + AssessmentMethodId + SamplingPointRepresentativenessAreaId"

    SamplingProcess {
        nvarchar ProcessId PK
        varchar CountryCode PK
        int AirPollutantCode
        nvarchar MeasurementType
        nvarchar MeasurementMethod
        nvarchar MeasurementEquipment
        nvarchar SamplingMethod
        int SamplingEquipment
        nvarchar AnalyticalTechnique
        nvarchar EquivalenceDemonstrated
        nvarchar DetectionLimit
        nvarchar DetectionLimitUnit
        nvarchar QAReport
        nvarchar EquivalenceDemonstrationReport
        nvarchar Documentation
    }
    ScenarioMeasure {
        nvarchar CountryCode PK
        nvarchar ScenarioId PK
        nvarchar MeasureGroupId PK
        float MeasureGroupAirPollutionReduction
        int AssessmentMethodId
    }
    ScenarioMeasure ||--o{ PlanScenario : "CountryCode + ScenarioId + MeasureGroupId"

    SourceApportionment {
        nvarchar CountryCode PK
        nvarchar SourceAppId PK
        int AirPollutantCode PK
        varchar ContributionType
        varchar SpatialScale
        varchar SourceSector
        float Contribution
    }
    SourceApportionment ||--o{ ComplianceAssessmentMethod : "via CompliancePlanLink (CountryCode + SourceAppId to AttainmentId)"

    Station {
        varchar CountryCode PK
        nvarchar AirQualityStationEoICode PK
        nvarchar AQStationName
        nvarchar AirQualityStationArea
    }
    Zone {
        char CountryCode PK
        char ZoneId PK
        nvarchar ZoneGeometry
    }
    Zone ||--o{ AssessmentRegime : "CountryCode + ZoneId"
```