```mermaid
erDiagram

AUTHORITY {
    nvarchar CountryCode PK
    nvarchar AuthorityInstanceId PK
    int Object PK "code list needed, e.g.: ‘1: reporting assessment data to EEA’, etc."
    nvarchar PersonEmail PK
    nvarchar AuthorityInstance "Code list : ‘zone’, ‘network’, ‘nuts0’, ‘station’, ‘model’, etc."
    nvarchar OrganisationName
    nvarchar OrganisationURL
    nvarchar OrganisationAddress
    nvarchar PersonName
    nvarchar AuthorityStatus "code list needed (‘active’, ‘inactive’).​"
}

STATION {
    varchar CountryCode PK
    nvarchar AirQualityStationEoICode PK "Must be always provided and cannot be modified,​"
    nvarchar AirQualityNetwork
    nvarchar AirQualityNetworkName
    nvarchar AirQualityNetworkOrganisationalLevel
    nvarchar Timezone
    nvarchar AirQualityStationNatCode
    nvarchar AQStationName
    nvarchar AirQualityStationArea
}
STATION ||--o{ SAMPLINGPOINT : "CountryCode + AirQualityStationEoICode"

SAMPLINGPOINT {
    varchar CountryCode PK
    nvarchar AssessmentMethodId PK
    nvarchar ProcessId PK "Can be re-used for the same equipment configurations under different sampling points."
    datetime2 ProcessActivityBegin PK
    datetime2 ProcessActivityEnd
    nvarchar SamplingPointRef
    int AirPollutantCode
    nvarchar AirQualityStationEoICode
    nvarchar AirQualityStationType
    int SuperSite
    numeric Latitude
    numeric Longitude
    numeric AltitudeMasl
    numeric InletHeightM
    numeric BuildingDistanceM
    numeric KerbDistanceM
}

SAMPLINGPOINT ||--|| SAMPLINGPROCESS : "CountryCode + ProcessId"
SAMPLINGPOINT }o--o{ MEASUREMENTRESULTS : "CountryCode + AirPollutantCode + AssessmentMethodId"
SAMPLINGPOINT }o--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + AirPollutantCode + AssessmentMethodId + DataAggregationProcessId to ProcessId"

SAMPLINGPROCESS {
    varchar CountryCode PK
    nvarchar ProcessId PK
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

MEASUREMENTRESULTS {
    varchar CountryCode PK
    varchar AssessmentMethodId PK
    int AirPollutantCode PK
    datetime Start PK "time zone must be included"
    datetime End PK "time zone must be included"
    decimal Value
    varchar Unit "Must follow recommended unit for AQD pollutants"
    varchar ObservationFrequency "Must be consistent with Start and End time"
    int Validity
    int Verification
    decimal DataCapture
    datetime ResultTime
}

SAMPLINGPOINT_SRA {
    varchar CountryCode PK
    nvarchar SamplingPointRepresentativenessAreaId PK
    float X PK "Project SRID3035 EEA common grid"
    float Y PK "Project SRID3035 EEA common grid"
    int SpatialResolution "10, 100, 1000 or 10000 m"
    varchar AssessmentMethodId
}

MODEL {
    varchar CountryCode PK
    nvarchar AssessmentMethodId PK
    varchar DataAggregationProcessId PK
    varchar AssessmentMethodName "e.g.: WRF-Chem, CHIMERE, etc."
    varchar AssessmentType
    int AirPollutantCode
    nvarchar ResultEncoding
    nvarchar ModelApplication
    decimal MQI
    nvarchar ModelReport
    nvarchar DataQualityReport
}
MODEL ||--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + AssessmentMethodId + DataAggregationProcessId"
MODEL ||--o{ MODELLINGRESULTS : "CountryCode + AssessmentMethodId + DataAggregationProcessId"
MODEL ||--o{ PLANSCENARIO : "CountryCode + AssessmentMethodId + DataAggregationProcessId"
MODEL ||--o{ SAMPLINGPOINT_SRA : "CountryCode + AssessmentMethodId"

MODELLINGRESULTS {
    varchar CountryCode PK
    varchar AssessmentMethodId PK
    datetime Start PK
    varchar DataAggregationProcessId PK
    float X PK "Projection SRID3035-EEA common grid"
    float Y PK "Projection SRID3035-EEA common grid"
    int AirPollutantCode
    datetime End
    decimal Value
    varchar Unit "Use the unit for AQD pollutants"
    int Validity
    int SpatialResolution "10, 100, 1000 or 10000 m"
    datetime ResultTime
}

ZONE {
    char CountryCode PK
    char ZoneId PK
    nvarchar ZoneGeometry "Projection: SRID4326 or SRID4258"
}
ZONE ||--o{ ASSESSMENTREGIME : "CountryCode + ZoneId"

ASSESSMENTREGIME {
    varchar CountryCode PK
    varchar AssessmentRegimeId PK
    varchar DataAggregationProcessId PK 
    int ReportingYear
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
ASSESSMENTREGIME ||--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + AssessmentRegimeId + DataAggregationProcessId"


COMPLIANCEASSESSMENTMETHOD {
    varchar CountryCode PK
    varchar AssessmentRegimeId PK
    nvarchar DataAggregationProcessId PK
    nvarchar AssessmentMethodId PK
    varchar ComplianceId PK
    int ReportingYear
    int AirPollutantCode
    nvarchar AssessmentType
    varchar AssessmentMethod
    int HotSpot
    varchar IsExceedance
    decimal AirPollutionLevel
    decimal AirPollutionLevelAdjusted
    decimal AbsoluteUncertaintyLimit "AbsoluteUncertaintyLimit must be reported for every AssessmentMethodId which refer to SamplingPoints"
    decimal RelativeUncertaintyLimit "RelativeUncertaintyLimit must be reported for every AssessmentMethodId which refer to SamplingPoints"
    decimal MaxRatioUncertainty "MaxRatioUncertainty must be reported for every AssessmentMethodId which refers to Model"
    char CorrectionFactor
    varchar AttainmentcId
    nvarchar SamplingPointRepresentativenessAreaId
    nvarchar PreliminaryReason "In case of exceedance ‘PreliminaryReason’ must not be null"
}
COMPLIANCEASSESSMENTMETHOD }o--o{ COMPLIANCEPLANLINK : "CountryCode + PlanId + ScenarioId"
COMPLIANCEASSESSMENTMETHOD }o--o{ SAMPLINGPOINT_SRA : "CountryCode + AssessmentMethodId + SamplingPointRepresentativenessAreaId"


ADJUSTMENT {
    nvarchar CountryCode PK
    varchar ComplianceId PK
    nvarchar DeductionAssessmentMethod PK
    nvarchar AdjustmentType
    nvarchar AdjustmentSource
    decimal MaxRatioUncertainty
}
ADJUSTMENT }o--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + ComplianceId + DeductionAssessmentMethod"
ADJUSTMENT }o--o{ MODEL : "CountryCode + ComplianceId + DeductionAssessmentMethod"

PLANSCENARIO {
    nvarchar CountryCode PK
    nvarchar PlanId PK
    nvarchar ScenarioId PK
    varchar PlanCategory
    varchar ScenarioCategory
    nvarchar AuthorityOrganisation
    nvarchar AuthorityWebsite
    varchar AuthorityLevel
    varchar ScenarioCode
    varchar DataAggregationProcessId
    float ScenarioAirPollutionLevel
    int ScenarioYear
    int AssessmentMethodId
    nvarchar SupportingDocumentation
}
PLANSCENARIO ||--o{ COMPLIANCEPLANLINK : "CountryCode + PlanId + ScenarioId"
PLANSCENARIO ||--o{ COMPLIANCEPLANLINK : "CountryCode + PlanId + ScenarioId"
PLANSCENARIO ||--o{ SCENARIOMEASURE : "CountryCode + PlanId + ScenarioId"

COMPLIANCEPLANLINK {
    varchar CountryCode PK
    varchar ComplianceId PK
    nvarchar PlanId PK
    nvarchar ScenarioId PK
    nvarchar SourceAppId PK
}
COMPLIANCEPLANLINK ||--o{ PLANSCENARIO : "CountryCode + PlanId + ScenarioId"
COMPLIANCEPLANLINK ||--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + PlanId + ScenarioId"
COMPLIANCEPLANLINK ||--o{ SOURCEAPPORTIONMENT : "CountryCode + PlanId + ScenarioId"
COMPLIANCEPLANLINK ||--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + SourceAppId to AttainmentId"


MEASURE {
    nvarchar CountryCode PK
    nvarchar MeasureGroupId PK
    nvarchar MeasureId PK
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

SCENARIOMEASURE {
    nvarchar CountryCode PK
    nvarchar ScenarioId PK
    nvarchar MeasureGroupId PK
    float MeasureGroupAirPollutionReduction
    int AssessmentMethodId
}
SCENARIOMEASURE ||--o{ PLANSCENARIO : "CountryCode + ScenarioId + MeasureGroupId"
SCENARIOMEASURE ||--o{ MEASURE : "CountryCode + PlanId + ScenarioId"


SOURCEAPPORTIONMENT {
    nvarchar CountryCode PK
    nvarchar SourceAppId PK
    int AirPollutantCode
    varchar ContributionType "background’, increment, ..."
    varchar SpatialScale "regional, urban, local, ..."
    varchar SourceSector
    float Contribution
}
SOURCEAPPORTIONMENT ||--o{ COMPLIANCEPLANLINK : "CountryCode + SourceAppId to AttainmentId"
```
