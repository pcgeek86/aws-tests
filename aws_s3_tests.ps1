$global:BucketName = (New-Guid).Guid

Describe 'Amazon S3 Tests' {

    It "Should successfully create an S3 Bucket" {
        { New-S3Bucket -BucketName $BucketName } | Should -Not -Throw
    }
    It "Should successfully delete an S3 Bucket" {
        { Remove-S3Bucket -BucketName $BucketName } | Should -Not -Throw
    }
}
