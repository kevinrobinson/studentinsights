class StarMathImporter < Struct.new :school_scope, :client

  def remote_file_name
    'SM.csv'
  end

  def data_transformer
    StarMathCsvTransformer.new
  end

  def filter
    SchoolFilter.new(school_scope)
  end

  def star_mathematics_assessment
    @assessment ||= Assessment.where(family: "STAR", subject: "Mathematics").first_or_create!
  end

  def import_row(row)
    date_taken = Date.strptime(row[:date_taken].split(' ')[0], "%m/%d/%Y")
    student = Student.find_by_local_id(row[:local_id])

    return if student.nil?

    existing_star_assessment = StudentAssessment.where({
      student_id: student.id,
      date_taken: date_taken,
      assessment: star_mathematics_assessment
    }).first

    if existing_star_assessment.nil?
      StudentAssessment.create!({
        student_id: student.id,
        date_taken: date_taken,
        assessment: star_mathematics_assessment,
        percentile_rank: row[:percentile_rank]
      })
    else
      existing_star_assessment.update_attributes({
        percentile_rank: row[:percentile_rank]
      })
    end
  end

  class HistoricalImporter < StarMathImporter
    # STAR sends historical data in a separate file

    def remote_file_name
      'SM_Historical.csv'
    end
  end

end
