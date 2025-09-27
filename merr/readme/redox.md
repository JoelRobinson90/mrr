Upload PDF to Redox -> Alayacare
====


Path: [Redox](../path/services/redox)


MRN is fixed based on order we are attaching to
File is local file for testing


```ruby
module Fetch
  class SummaryPull
    def with_patient
      mrn = "610408"

      patient = FactoryBot.build(:patient)

      demand_partner = patient.demand_partner

      demand_partner.redox_destinations =
        [FactoryBot.build(:redox_destination, demand_partner:       demand_partner,
                                              redox_destination_id: "0ce1bb58-d1be-4cd8-8820-15cd88f0ab87",
                                              name:                 "Millenium Physician Group Athena PREVIEW CCDA Query Destination (p)",
                                              data_model:           "Clinical Summary",
                                              department:           "442")]

      patient.save!
      patient

      Redox::ClinicalSummaryService.call(patient)
    end
  end

  class Pdf
    def with_patient
      mrn = "610408"

      order = FactoryBot.build(:order)
      patient = order.patient

      demand_partner = patient.demand_partner
      patient.medical_record_number = mrn

      demand_partner.redox_destinations =
        [FactoryBot.build(:redox_destination, demand_partner:       demand_partner,
                                              redox_destination_id: "7b586c7f-fc6c-4e2f-b95f-150616814a08",
                                              name:                 "Millenium Physician Group Athena PREVIEW CCDA Query Destination (p)",
                                              data_model:           "Results",
                                              department:           "442")]

      patient.save!
      patient

      # order location provider department
      file_blob = File.open("./test.pdf")

      pdf = Alayacare::Pdf.new("TestPDF", file_blob, order)

      Redox::ResultService.call(pdf)
    end
  end
end
```
