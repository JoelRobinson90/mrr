# typed: true
# frozen_string_literal: true

module Alayacare
  module FormTemplate
    class Form100a
      class << self

        def collect_field_tags(questions)
          questions.pluck(:field_tag)
        end

        def bathroom_block
          [
            {
              field_tag: "field_622",
              question:  "Sidewalk and/or pathway to house is level and free from any hazards.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_651",
              question:  "Grab bar is attached near toilet for assistance.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_650",
              question:  "Toilet has a raised seat.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_649",
              question:  "Tub and/or shower have a grab bar for stability.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_638",
              question:  "Tub and shower have a non-slip surface.",
              processor: :single_response_with_other
            }

          ]
        end

        def stairs_block
          [
            {
              field_tag: "field_646",
              question:  "Stairway is adequately lit.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_645",
              question:  "Stairs are free from any clutter.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_644",
              question:  "Handrail is present and sturdy.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_643",
              question:  "Carpet is properly secured to stairs and/or all wood is properly secured.",
              processor: :single_response_with_other
            }
          ]
        end

        def kitchen_block
          [
            {
              field_tag: "field_641",
              question:  "ABC fire extinguisher is located in kitchen.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_640",
              question:  "Kitchen lighting is adequate and easy to reach switches.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_639",
              question:  "Oven controls are within easy reach.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_638",
              question:  "Floor mats are non-slip tread and secured to floor.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_637",
              question:  "Step stool is present, is sturdy and has handrail.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_636",
              question:  "Items used most often are within easy reach on low shelves.",
              processor: :single_response_with_other
            }

          ]
        end

        def living_room_block
          [
            {
              field_tag: "field_634",
              question:  "Emergency numbers are printed near all phones in house.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_633",
              question:  "Phone is readily accessible near favorite seating areas.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_632",
              question:  "All lighting has an easily accessible on/off switch.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_631",
              question:  "Lighting is adequate to light room.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_630",
              question:  "All rugs are secured to floor with double-sided tape.",
              processor: :single_response_with_other
            },
            {
              question:  "Do you have hardwood floors or carpeting (helpful to know if they’re on a walker or at risk of tripping)?",
              field_tag: "field_",
              processor: :text
            },
            {
              field_tag: "field_629",
              question:  "All cords are either behind furniture or secured in a manner that does not cause trip hazards.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_654",
              question:  "Floor is free from clutter.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_627",
              question:  "Furniture is of adequate height and offers arm rests that assist in getting up and down.",
              processor: :single_response_with_other
            }

          ]
        end

        def outside_of_house_block
          [
            {
              field_tag: "field_625",
              question:  "Porch lights are working and provide adequate lighting.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_",
              question:  "Outside stairs are stable and have sturdy handrail.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_623",
              question:  "Driveway is free from debris/snow/ice.",
              processor: :single_response_with_other
            },
            {
              question:  "Do you have stairs to enter your home or in your home?",
              field_tag: "field_",
              processor: :text
            }

          ]
        end

        def ability_to_get_appointments_block
          [
            {
              question:  "Do you need help getting to your appointments?",
              field_tag: "field_244",
              processor: :text
            },
            {
              question:  "How do you get to your appointments?",
              field_tag: "field_242",
              processor: :text
            }

          ]
        end

        def tobbaco_block
          [
            {
              question:  "Do you use any marijuana products?",
              field_tag: "field_240",
              processor: :text
            },
            {
              question:  "Are there any other illicit/street drugs that you use?",
              field_tag: "field_412",
              processor: :text
            },
            {
              question:  "How many drinks of alcohol do you have per week?",
              field_tag: "field_238",
              processor: :text
            },
            {
              field_tag: "field_2077",
              question:  "How often do you smoke cigarettes?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_2080",
              question:  "Have you ever smoked before?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_2333",
              question:  "Do you currently smoke?",
              processor: :single_response_with_other
            },
            {
              question:  "What drinks containing alcohol do you drink?",
              field_tag: "field_239",
              processor: :text
            },
            {
              question:  "Are you open to quitting currently?",
              field_tag: "field_237",
              processor: :single_response_with_other
            },
            {
              question:  "Have you tried to quit in the past?",
              field_tag: "field_236",
              processor: :single_response_with_other
            },
            {
              question:  "If so, when did you quit? How many years did you smoke? On average, how much did you smoke a day?",
              field_tag: "field_",
              processor: :text
            }
          ]
        end

        def allergens_block
          [
            {
              question:  "Ask them if anyone in their home smokes.",
              field_tag: "field_619",
              processor: :text
            },
            {
              question:  "Have they noticed any mold in their home? If so ask them to show you where and note details.",
              field_tag: "field_617",
              processor: :text
            },
            {
              question:  "Ask them if they have any pets. If so, describe what kind, breed to understand what level of dander there may be in the home.",
              field_tag: "field_616",
              processor: :text
            }
          ]
        end

        def ability_to_purchase_medications_block
          [
            {
              field_tag: "field_228",
              question:  "Do you have medications that you cannot afford to purchase consistently?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_244176",
              question:  "Do you need help getting your medications?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_2074",
              question:  "Can you have your prescriptions mailed or delivered?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_2073",
              question:  "Do you pick up your medications?",
              processor: :single_response_with_other
            },
            {
              question:  "How do you purchase your medications?",
              field_tag: "field_224",
              processor: :text
            },
            {
              question:  "Were you able to get all of the new medications on your discharge instructions?",
              field_tag: "field_411",
              processor: :text
            }
          ]
        end

        def diet_block
          [
            {
              question:  "Do you often eat out or order in food and where?",
              field_tag: "field_216",
              processor: :text
            },
            {
              question:  "What are the snacks you choose?",
              field_tag: "field_213",
              processor: :text
            },
            {
              question:  "How many snacks do you have in a day",
              field_tag: "field_212",
              processor: :text
            },

            {
              question:  "What do you eat for breakfast, lunch and dinner?",
              field_tag: "field_211",
              processor: :text
            }
          ]
        end

        def review_plan
          [
            {
              question:  "Ask patient to repeat back their understanding of what was identified in the visit and why they need recommended appointments? Record any notes	942	patient and daughter verbally express understanding of todays suggestions.",
              field_tag: "field_416",
              processor: :text
            },
            {
              question:  "Ask patient how he/she intends to get to that appointment",
              field_tag: "field_417",
              processor: :text
            },
            {
              question:  "Ask patient to tell you how he/she will take her medications to reaffirm medication reconciliation",
              field_tag: "field_418",
              processor: :text
            },
            {
              question:  "Inform patient when MA will be returning and record any relevant information",
              field_tag: "field_422",
              processor: :text
            }
          ]
        end

        def patient_exam_footer
          [
            {
              question:  "Summary of Patient Exam",
              field_tag: "field_1201",
              processor: :text
            },
            {
              question:  "Examine lower extremities for edema and record findings",
              field_tag: "field_196",
              processor: :text
            },
            {
              question:  "Examine lower extremities for skin breakdown that is visible while clothed and record findings",
              field_tag: "field_575",
              processor: :text
            },
            {
              question:  "Palpate abdomen for tenderness and record findings",
              field_tag: "field_195",
              processor: :text
            },
            {
              question:  "Auscultate Heart and record findings",
              field_tag: "field_194",
              processor: :text
            },
            {
              question:  "Auscultate Lungs and record findings",
              field_tag: "field_191",
              processor: :text
            },

            {
              question:  "Conduct Cursory Head and Neck Exam and record observations",
              field_tag: "field_190",
              processor: :text
            }
          ]
        end

        def allergies_table
          [
            {
              question:  "Do you have any allergies?",
              field_tag: "field_2064",
              processor: :allergies
            }
          ]
        end

        def medications_footer
          [
            {
              field_tag: "field_2069",
              question:  "Have patient repeat back how they are going to take their medications (both pre and post hospitalization medications). Were they able to repeat this back correctly?",
              processor: :single_response_with_other
            },
            {
              question:  "Ask patient if he/she is tolerating any of the new medications and take notes here",
              field_tag: "field_2067",
              processor: :text
            },
            {
              question:  "Reconcile the discharge instructions with the new medications and take notes here",
              field_tag: "field_384",
              processor: :text
            }
          ]
        end

        def medications
          [
            {
              question:  "Watch for shortness of breath and fatigue - How often patient has to stop?",
              field_tag: "field_379",
              processor: :text
            },
            {
              question:  "Observe patient’s ability to locate medications and take notes",
              field_tag: "field_378",
              processor: :text
            },
            {
              question:  "Ask patient to gather any supplements or over the counter medications that are regularly being used",
              field_tag: "field_2067",
              processor: :text
            }
          ]
        end

        def medications_table
          [
            {
              question:  "List all Medications",
              field_tag: "field_2065",
              processor: :medications
            }
          ]
        end

        def past_medical_history
          [
            {
              question:  "What was the reaction that you had? Rash, shortness of breath, feeling like your throat was closing?",
              field_tag: "field_109",
              processor: :text
            },
            {
              question:  "Have you ever had any surgeries?",
              field_tag: "field_107",
              processor: :text
            },
            {
              question:  "Patient Self-Reported Vaccinations",
              field_tag: "field_189",
              processor: :patient_self_reported_vaccinations
            },
            {
              question:  "Past Medical Diagnoses",
              field_tag: "field_2056",
              processor: :past_medical_diagnoses
            }
          ]
        end

        def history_of_present_illness
          [
            {
              question:  "Summary of History of Present Illness",
              field_tag: "field_1196",
              processor: :text
            },
            {
              question:  "Do you have any of the following?",
              field_tag: "field_2062",
              processor: :any_of_the_following
            },
            {
              question:  "Overall Summary of Patient",
              field_tag: "field_1195",
              processor: :text
            },
            {
              question:  "Are you eating well?",
              field_tag: "field_352",
              processor: :text
            },
            {
              question:  "Are you tolerating liquids?",
              field_tag: "field_351",
              processor: :text
            },
            {
              field_tag: "field_2058",
              question:  "Are you able to care for yourself?",
              processor: :single_response_with_other
            },
            {
              question:  "Are you tolerating food?",
              field_tag: "field_350",
              processor: :text
            },
            {
              question:  "Is it hard to go from sitting to standing?",
              field_tag: "field_357",
              processor: :text
            },
            {
              question:  "Do you have anyone who is helping you?",
              field_tag: "field_347",
              processor: :text
            },
            {
              question:  "Have you noticed any safety issues in your home since discharge now that you’re in weakened condition?",
              field_tag: "field_349",
              processor: :text
            },
            {
              question:  "Ask patient to tell you how he/she will take her medications to reaffirm medication reconciliation",
              field_tag: "field_418",
              processor: :text
            }
          ]
        end

        def summary_of_visits
          [
            {
              question:  "Allow patient to broadly answer in his/her own words and record their responses",
              field_tag: "field_94",
              processor: :text
            },
            {
              field_tag: "field_2077",
              question:  "How often do you smoke cigarettes?",
              processor: :single_response_with_other
            }
          ]
        end

        def text_questions
          [
            {
              question:  "I Agree",
              field_tag: "id_1",
              processor: :text
            },
            {
              question:  "Summary of Vitals",
              field_tag: "field_1200",
              processor: :text
            },
            {
              question:  "Ask patient \"Can you bring me the discharge instructions you were given?\"",
              field_tag: "field_2068",
              processor: :text
            },
            {
              question:  "Ask the patient to show you how he/she takes each medication and take notes if needed",
              field_tag: "field_418",
              processor: :text
            },
            {
              question:  "Summary of Med Rec",
              field_tag: "field_1198",
              processor: :text
            },
            {
              question:  "Summary of Social History",
              field_tag: "field_1202",
              processor: :text
            },
            {
              question:  "Summarize Plan Review with Patient",
              field_tag: "field_1203",
              processor: :text
            }
          ]
        end

        def yes_no_option_questions
          [
            {
              field_tag: "field_660",
              question:  "CO detectors on each floor of house and tested.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_671",
              question:  "All O2 tubing is less than 50 ft. and is not a trip hazard.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_663",
              question:  "All heaters are away from any type of flammable material.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_664",
              question:  "Are there any issues or hazards to having oxygen in the home?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_673",
              question:  "Resident has the proper hearing and visual aids prescribed and are in good working order.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_665",
              question:  "Are there any issues or hazards to having pets in the home?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_666",
              question:  "Oxygen equipment inspected and current.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_659",
              question:  "Smoke detectors in all areas of the house (each floor) and tested.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_349",
              question:  "Have you noticed any safety issues in your home since discharge now that you’re in weakened condition?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_2081",
              question:  "Have you ever missed an appointment due to transportation?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_662",
              question:  "Resident has all medical information readily available and in an area emergency providers will easily find.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_2059",
              question:  "Do you need to have arrangements made for a Home Health Aide?",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_668",
              question:  "Homeowner has good non-skid shoes to move around house.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_628",
              question:  "Floor is free from any clutter that would create tripping hazards.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_655",
              question:  "Light is near bed and is easy to turn on.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_669",
              question:  "All assisted walking devices are readily accessible and in good condition.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_656",
              question:  "Phone is next to bed and within easy reach.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_661",
              question:  "Flashlights are handy throughout the home.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_670",
              question:  "There is a phone near the floor for ease of reach in case of a fall.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_657",
              question:  "Flashlight is near bed in case of emergency.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_652",
              question:  "Pathway from bedroom to bathroom is free from clutter and well-lit for ease of movement in the middle of the night.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_672",
              question:  "Resident has had an annual hearing and vision check by a physician.",
              processor: :single_response_with_other
            },
            {
              field_tag: "field_674",
              question:  "All medications are properly stored and labeled to avoid confusion on dosage, time to take, and avoidance of missed doses.",
              processor: :single_response_with_other
            }
          ]
        end

        def complex_parser
          [
            {
              question:  "Pulse Ox",
              field_tag: "field_146",
              processor: :pulse_ox
            },
            {
              question:  "Height",
              field_tag: "field_144",
              processor: :height
            },
            {
              question:  "Weight",
              field_tag: "field_145",
              processor: :weight_with_unit
            },
            {
              question:  "Temperature",
              field_tag: "field_2071",
              processor: :temperature_and_unit
            },
            {
              question:  "Body Mass Index",
              field_tag: "field_147",
              processor: :bmi
            },
            {
              question:  "Blood Pressure",
              field_tag: "field_142",
              processor: :blood_pressure
            },
            {
              question:  "Pulse",
              field_tag: "field_143",
              processor: :pulse
            },
            {
              question:  "Immunizations Administered during visit",
              field_tag: "field_",
              processor: :immunizations_administered
            },
            {
              question:  "Respiratory Rate",
              field_tag: "field_2070",
              processor: :respiratory_rate
            }
          ]
        end

        def attachment_questions
          [
            {
              question:  "Take photo of anything notable",
              field_tag: "field_",
              processor: :attachment
            },
            {
              question:  "Signature",
              field_tag: "id_2",
              processor: :attachment
            }
          ]
        end

        def questions
          [
            ability_to_get_appointments_block,
            ability_to_purchase_medications_block,
            allergens_block,
            allergies_table,
            attachment_questions,
            bathroom_block,
            complex_parser,
            diet_block,
            history_of_present_illness,
            kitchen_block,
            living_room_block,
            medications,
            medications_footer,
            medications_table,
            outside_of_house_block,
            past_medical_history,
            patient_exam_footer,
            review_plan,
            stairs_block,
            summary_of_visits,
            text_questions,
            tobbaco_block,
            yes_no_option_questions
          ].reduce([], :concat)
        end
    end
    end
  end
end
