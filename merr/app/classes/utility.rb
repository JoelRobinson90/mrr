# frozen_string_literal: true

# typed: true
class Utility
  def self.display_phone(phone)
    return phone if phone.blank?

    if phone.length == 12
      "(#{phone[2..4]}) #{phone[5..7]}-#{phone[8..11]}"
    else
      phone
    end
  end

  def self.sanitize_phone(phone)
    return phone if phone.blank?

    phone_digits = phone.gsub(/\D/, "")
    case phone_digits.length
    when 10
      "+1#{phone_digits}"
    when 11
      "+#{phone_digits}"
    else
      phone
    end
  end

  def self.sanitize_date(date)
    return date unless date && date.length == 10

    return date unless date[2] == "/" && date[5] == "/"

    date_parts = date.split("/")
    "#{date_parts[2]}-#{date_parts[0]}-#{date_parts[1]}"
  end

  def self.display_date(date)
    return date if date.blank?

    date.strftime("%m/%d/%Y")
  end
end
