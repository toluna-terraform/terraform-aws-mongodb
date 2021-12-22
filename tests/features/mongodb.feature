Feature: Check mongodb module

    Scenario Outline: Check module resources
        Given I have <resource_name> defined
        

    Examples:
    | resource_name              |
    | aws_ssm_parameter          |
    | template_file              |
    | mongodbatlas_cluster       |
    | mongodbatlas_database_user |
    | null_resource              |
    | random_password            |

    Scenario: Check cluster name
        Given I have mongodbatlas_cluster defined
        Then Its name must be chorus-test
       

    Scenario: Check dbuser name
        Given I have mongodbatlas_database_user defined
        Then Its username must be chorus-test-dbuser

