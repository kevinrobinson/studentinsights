require 'rails_helper'

RSpec.describe FileImport do
  let(:log) { LogHelper::Redirect.instance.file }
  let(:mock_client) { double(:sftp_client, read_file: File.read(log)) }
  let(:importer) { StudentsImporter.new(nil, mock_client, log, true) }
  let(:fake_data) { [] }

  subject { FileImport.new importer }

  let(:log_contents) { File.read(log) }

  describe '#import' do

    it 'runs the data through the CSV transformer' do
      expect_any_instance_of(CsvTransformer).to receive(:transform).and_return(fake_data)
      subject.import
    end

    it 'prints an accurate cleanup report' do
      subject.import
      log.close do
        expect(log_contents).to include 'Importing students_export.txt...

         0 rows of data in students_export.txt pre-cleanup
         0 rows of data in students_export.txt post-cleanup'
      end
    end

    it 'calls import_row with rows that the filter includes' do
      pending
    end

    it 'does not call import_row with rows that the filter excludes' do
      pending
    end

    it 'prints a progress bar' do
      pending
    end

  end

end
