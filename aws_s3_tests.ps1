Describe 'Amazon S3 Tests' {
    BeforeAll {
        $BucketName = (New-Guid).Guid
    }

    It "Should successfully create an S3 Bucket" {
        { New-S3Bucket -BucketName $BucketName; Start-Sleep -Seconds 2 } | Should -Not -Throw
    }
    It 'Should upload an object to S3 Bucket' {
        { 
          (New-Guid).Guid | Set-Content -Path tempfile.txt
          Write-S3Object -BucketName $BucketName -File tempfile.txt
          Remove-Item -Path tempfile.txt
        } | Should -Not -Throw
    }
    It 'Should delete an object from an Amazon S3 Bucket' {
        { Remove-S3Object -BucketName $BucketName -Key tempfile.txt -Force } | Should -Not -Throw
    }
    It "Should successfully delete an S3 Bucket" {
        { Remove-S3Bucket -BucketName $BucketName -DeleteBucketContent -Force } | Should -Not -Throw
    }
}
