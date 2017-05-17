class ImportPeopleFromSpreadsheetJob < ActiveJob::Base
  queue_as :default

  def perform(upload_job_id)
    job = UploadJob.find(upload_job_id)
    Import::ImportPeopleFromSpreadsheet.call(job: job)
  rescue => e
    job&.fail!(e.message)
  ensure
    job&.remove_file!
  end
end