# frozen_string_literal: true

# typed: true
module GeneratePapertrail
  class << self
    def thrash_patients
      return false unless Rails.env.development?

      20.times { FactoryBot.create(:patient, :with_pharmacy, :with_address, :with_insurance) } if Patient.count < 20

      mod_columns = Patient.column_names.reject {|cn| (cn =~ /_id/) }
      mod_columns = mod_columns.filter {|cn| cn !~ /_at/ }
      mod_columns = mod_columns.filter {|cn| cn != "id" }

      @patients = Patient.all
      @patients.each do |patient|
        altered_patient = FactoryBot.build(:patient)
        appointment = FactoryBot.create(:appointment, patient: patient)

        mod_columns.each do |col|
          patient.send("#{col}=", altered_patient.send(col.to_s))
          patient.save!
        rescue StandardError => e
          Rails.logging.debug("#{e} occured while altering patients")
        end
      end
    end

    def thrash_appointments
      return false unless Rails.env.development?

      20.times { FactoryBot.create(:appointment) } if Appointment.count < 20

      mod_columns = Appointment.column_names.reject {|cn| (cn =~ /_id/) }
      mod_columns = mod_columns.filter {|cn| cn !~ /_at/ }
      mod_columns = mod_columns.filter {|cn| cn != "id" }

      @appointments = Appointment.all
      @appointments.each do |appointment|
        altered_appointment = FactoryBot.build(:appointment)

        mod_columns.each do |col|
          appointment.send("#{col}=", altered_appointment.send(col.to_s))
          appointment.save!
        rescue StandardError => e
          Rails.logging.debug("#{e} occured while altering patients")
        end
      end
    end
  end
end
