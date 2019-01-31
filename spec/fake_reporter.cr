require "../src/crytic/reporter/reporter"

class FakeReporter < Crytic::Reporter::Reporter
  getter events
  @events = [] of String

  def report_original_result(original_result)
    @events << "report_original_result"
  end

  def report_mutations(mutations)
    @events << "report_mutations"
  end

  def report_neutral_result(result)
    @events << "report_neutral_result"
  end

  def report_result(result)
    @events << "report_result"
  end

  def report_summary(results)
    @events << "report_summary"
  end

  def report_msi(results)
    @events << "report_msi"
  end
end
