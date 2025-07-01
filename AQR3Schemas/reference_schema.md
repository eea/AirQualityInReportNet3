```mermaid
erDiagram

AUTHORITY {
    nvarchar Country
    nvarchar CountryCode "not null"
    nvarchar AuthorityInstance "not null"
    nvarchar AuthorityInstanceId "not null"
    int Object "not null"
    nvarchar OrganisationName
    nvarchar OrganisationURL
    nvarchar OrganisationAddress
    nvarchar PersonName "not null"
    nvarchar PersonEmail "not null"
    datetime ReportingTime "not null"
}

STATION {
    varchar Country
    varchar CountryCode
    char City
    varchar CityCode
    nvarchar AirQualityNetwork
    nvarchar AirQualityNetworkName
    int AirQualityNetworkOrganisationalLevel
    nvarchar Timezone
    nvarchar AirQualityStationEoICode
    nvarchar AirQualityStationNatCode
    nvarchar AQStationName
    nvarchar AirQualityStationArea
    datetime ReportingTime "not null"
}
STATION ||--o{ SAMPLINGPOINT : "CountryCode + AirQualityStationEoICode"

SAMPLINGPOINT {
    varchar Country
    varchar CountryCode
    nvarchar AirQualityStationEoICode
    nvarchar AssessmentMethodId
    nvarchar SamplingPointRef
    nvarchar AirPollutant
    int AirPollutantCode
    nvarchar AirQualityStationType
    int SuperSite
    numeric Latitude
    numeric Longitude
    numeric Altitude(masl)
	numeric InletHeight(m) 
	numeric BuildingDistance(m)
	numeric KerbDistance(m)
    nvarchar ProcessId
    datetime2 ProcessActivityBegin
    datetime2 ProcessActivityEnd
    varchar SamplingPointStatus "not null"
    float X
    float Y
    bigint GridNum10m
    bigint GridNum100m
    bigint GridNum1km
    bigint GridNum10km
    datetime ReportingTime "not null"
}
SAMPLINGPOINT ||--|| SAMPLINGPROCESS : "CountryCode + ProcessId"
SAMPLINGPOINT }o--o{ MEASUREMENTRESULTS : "CountryCode + AirPollutantCode + AssessmentMethodId"
SAMPLINGPOINT }o--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + AirPollutantCode + AssessmentMethodId + DataAggregationProcessId to ProcessId"

SAMPLINGPROCESS {
    varchar Country
    varchar CountryCode
    nvarchar AirPollutant
    int AirPollutantCode
    nvarchar ProcessId
    datetime2 ProcessActivityBegin
	datetim2 ProcessActivityEnd
    nvarchar MeasurementType
    nvarchar MeasurementMethod
    nvarchar MeasurementEquipment
    nvarchar SamplingMethod
    int SamplingEquipment
    nvarchar AnalyticalTechnique
    nvarchar EquivalenceDemonstrated
    nvarchar DataQualityReportURL
    nvarchar EquivalenceDemonstrationReportURL
    nvarchar ProcessDocumentationURL
    int Deletion "Not Null"
}

MEASUREMENTRESULTS {
    varchar CountryCode
    nvarchar SamplingPointRef
    nvarchar AirPollutant
    int AirPollutantCode
    date Start
    date End
    numeric Value
    nvarchar Unit
    nvarchar ObservationFrequency
    int Validity
    int Verification
    numeric DataCapture
    datetime2 ResultTime
    numeric DataCoverage
    nvarchar DataAggregationProcessId
    nvarchar DataAggregationProcess
    varchar SourceDataFlow
}

SAMPLINGPOINT_SRA {
    varchar CountryCode
    nvarchar SamplingPointRepresentativenessAreaId
    float X
    float Y
    int SpatialResolution "not null"
    bigint GridNum10m
    bigint GridNum100m
    bigint GridNum10km
    bigint GridNum1km
    varchar AssessmentMethodId
}
SAMPLINGPOINT }o--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + AssessmentMethodId + SamplingPointRepresentativenessAreaId"

MODELLINGRESULTS {
    varchar CountryCode
    varchar AssessmentMethodId
    varchar AirPollutant
    int AirPollutantCode
    datetime Start
    datetime End
    decimal Value
    varchar Unit
    int Validity
    int Verification "not null"
    datetime ResultTime
    varchar DataAggregationProcessId
    varchar DataAggregationProcess
    varchar SourceDataFlow "not null"
    float X
    float Y
    int SpatialResolution "not null"
    int GridNum10m
    int GridNum100m
    bigint GridNum1km
    bigint GridNum10km
}

MODEL {
    varchar Country
    varchar CountryCode
    nvarchar AssessmentMethodId "not null"
    varchar AssessmentMethodName "not null"
    nvarchar AssessmentType
    nvarchar AirPollutant
    int AirPollutantCode
    varchar DataAggregationProcessId
    nvarchar DataAggregationProcess
    nvarchar ResultEncoding
    nvarchar ModelApplication
    nvarchar ModelReportURL
    nvarchar DataQualityReportURL
    decimal MQI
}
MODEL ||--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + AssessmentMethodId + AirPollutantCode + DataAggregationProcessId"
MODEL ||--o{ MODELLINGRESULTS : "CountryCode + AssessmentMethodId + AirPollutantCode + DataAggregationProcessId"
MODEL ||--o{ PLANSCENARIO : "CountryCode + AssessmentMethodId + AirPollutantCode + DataAggregationProcessId"
MODEL ||--o{ SAMPLINGPOINT_SRA : "CountryCode + AssessmentMethodId"

ZONE {
    char CountryCode PK
    char ZoneId PK
    nvarchar ZoneGeometry
}
ZONE ||--o{ ASSESSMENTREGIME : "CountryCode + ZoneId"
ZONE ||--o{ GRIDZONE : "CountryCode + ZoneId"

GRIDZONE {
    char CountryCode
    char ZoneId
    float X
    float Y
    bigint GridNum100m
    bigint GridNum1km
    bigint GridNum10km
}

ASSESSMENTREGIMEZONE {
    nvarchar Country
    varchar CountryCode
    int ReportingYear
    varchar AssessmentRegimeId
    varchar ZoneId
    nvarchar ZoneCode
    decimal ZoneArea
    varchar ZoneCategory
    nvarchar ZoneType
    varchar ZoneName
    nvarchar AirPollutant
    int AirPollutantCode
    nvarchar ProtectionTarget
    nvarchar ObjectiveType
    nvarchar ReportingMetric
    varchar DataAggregationProcess
    varchar DataAggregationProcessId
    nvarchar AssessmentThresholdExceedance
    int PostponementYear
    int FixedSPOReduction
    int ZoneResidentPopulationYear
    int ZoneResidentPopulation
    int ClassificationYear
    varchar ClassificationReportURL    
    int RequiredNumberOfFixedSPO
	int ReportedNumberOfFixedSPO
	int RequiredNumberOfFixedRandomSPO
	int ReportedNumberOfFixedRandomSPO
	int RequiredNumberOfIndicativeSPO
	int ReportedNumberOfIndicativeSPO
	int RequiredNumberOfOBESPO
	int ReportedNumberOfOBESPO
	int RequiredNumberOfModels
	int ReportedNumberOfModels
	int Deletion "not null"
}
ASSESSMENTREGIMEZONE ||--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + ReportingYear + AssessmentRegimeId + DataAggregationProcessId"

COMPLIANCEASSESSMENTMETHOD {
    nvarchar Country
    varchar CountryCode
    int ReportingYear
    varchar AssessmentRegimeId "not null"
    nvarchar AirPollutant
    int AirPollutantCode
    nvarchar DataAggregationProcessId
    nvarchar AssessmentType
    varchar AssessmentMethod
    int HotSpot
    nvarchar AssessmentMethodId
    varchar IsExceedance "not null"
    decimal AirPollutionLevel
    decimal AirPollutionLevelAdjusted
    decimal AbsoluteUncertaintyLimit
    decimal RelativeUncertaintyLimit
    decimal MaxRatioUncertainty
    char CorrectionFactor
    varchar AttainmentId
    varchar ComplianceId
    nvarchar SamplingPointRepresentativenessAreaId
    nvarchar PreliminaryReason
    decimal EEA_AirPollutionLevel
    decimal EEA_AirPollutionLevelAdjusted
    varchar EEA_Exceedance_Assessment
    float EEA_estimationOfMQI
}
COMPLIANCEASSESSMENTMETHOD }o--o{ COMPLIANCEPLANLINK : "CountryCode + PlanId + ScenarioId"
COMPLIANCEASSESSMENTMETHOD }o--o{ SAMPLINGPOINT_SRA : "CountryCode + AssessmentMethodId + SamplingPointRepresentativenessAreaId"

ADJUSTMENT {
    nvarchar Country
    varchar CountryCode
    varchar AttainmentId
    nvarchar Adj_AssessmentMethodId
    nvarchar AdjustmentSource
    decimal MaxRatioUncertainty
    int Deletion "not null"
}
ADJUSTMENT }o--o{ COMPLIANCEASSESSMENTMETHOD : "CountryCode + AttainmentId + AssessmentMethod"
ADJUSTMENT }o--o{ MODEL : "CountryCode + AssessmentMethodId + AssessmentMethodName"

PLANSCENARIO {
    nvarchar Country
    nvarchar CountryCode
    nvarchar ScenarioId "not null"
    nvarchar ScenarioCode
    nvarchar AirPollutant
    nvarchar AirPollutantCode
    varchar DataAggregationProcess
    varchar DataAggregationProcessId
    varchar ScenarioCategory "not null"
    int ScenarioYear
    float ScenarioAirPollutionLevel
    int AssessmentMethodId
    nvarchar PlanId
    varchar PlanCategory
    nvarchar AuthorityOrganisation
    nvarchar AuthorityWebsite
    varchar AuthorityLevel
    nvarchar SupportingDocumentationURL
}
PLANSCENARIO ||--o{ COMPLIANCEPLANLINK : "CountryCode + PlanId + ScenarioId"
PLANSCENARIO ||--o{ COMPLIANCEPLANLINK : "CountryCode + PlanId + ScenarioId"
PLANSCENARIO ||--o{ SCENARIOMEASURE : "CountryCode + PlanId + ScenarioId"

COMPLIANCEPLANLINK {
    nvarchar Country
    varchar CountryCode
    int ReportingYear
    varchar ComplianceId "not null"
    nvarchar PlanId
    nvarchar SourceAppId
    nvarchar ScenarioId
}

MEASURE {
    nvarchar Country
    nvarchar CountryCode
    nvarchar MeasureGroupId "not null"
    nvarchar MeasureId "not null"
    nvarchar MeasureCode "not null"
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
    int ReasonIfMeasureNotUsed "not null"
    datetime ReportingTime
}

SCENARIOMEASURE {
    nvarchar Country
    nvarchar CountryCode
    nvarchar ScenarioId
    nvarchar AirPollutant
    nvarchar AirPollutantCode
    varchar DataAggregationProcess
    varchar DataAggregationProcessId
    nvarchar MeasureGroupId "not null"
    float MeasureGroupAirPollutionReduction
    int AssessmentMethodId
}
SCENARIOMEASURE ||--o{ PLANSCENARIO : "CountryCode + ScenarioId + MeasureGroupId"
SCENARIOMEASURE ||--o{ MEASURE : "CountryCode + PlanId + ScenarioId"

SOURCEAPPORTIONMENT {
    nvarchar Country
    nvarchar CountryCode
    nvarchar SourceAppId "not null"
    nvarchar AirPollutant
    int AirPollutantCode
    varchar ContributionType
    varchar SpatialScale
    varchar SourceSector
    float Contribution
}
SOURCEAPPORTIONMENT ||--o{ COMPLIANCEPLANLINK : "CountryCode + SourceAppId to AttainmentId"

ADMINBOUNDARYGRID {
    smallint adm_id "not null"
    bigint GridNum100m
    bigint GridNum10km
    bigint GridNum1km
    int Year
    int Population
}
ADMINBOUNDARYGRID ||--|| ADMINBOUNDARYLOOKUP_ADM_EEA39_2021 : "adm_id"

ADMINBOUNDARYLOOKUP_ADM_EEA39_2021 {
    smallint adm_id "not null"
    nvarchar ICC "not null"
    nvarchar adm_country "not null" 
    nvarchar level3_name "not null"
    nvarchar level2_name "not null"
    nvarchar level1_name "not null"
    nvarchar level0_name "not null"
    nvarchar level3_code "not null"
    nvarchar level2_code "not null"
    nvarchar level1_code "not null"
    nvarchar level0_code "not null"
    bit EEA32_2020 "not null"
    bit EEA38_2020 "not null"
    bit EEA39 "not null"
    bit EEA33 "not null"
    bit eea32 "not null"
    bit eu27_nouk "not null"
    bit EU28 "not null"
    bit eu27 "not null"
    bit EU25 "not null"
    bit EU15 "not null"
    bit EU12 "not null"
    bit EU10 "not null"
    tinyint EFTA4 "not null"
    nvarchar NUTS_EU "not null"
    nvarchar TAA "not null"
}

VOCABULARYRELATIONS {
    varchar Vocabulary "not null"
    varchar RelatedVocabulary "not null"
    varchar Concept_notation "not null"
    varchar Related_notation "not null"
}
VOCABULARYRELATIONS ||--o{ VOCABULARY : "vocabulary + Notation as Concept_notation"

VOCABULARY {
    varchar vocabulary "not null"
    varchar Notation "not null"
    varchar URI "not null"
    varchar Label
    varchar Definition
    varchar Note
    varchar Status
    date StatusModifiedDate
    date AcceptedDate
    date NotAcceptedDate
}
```


