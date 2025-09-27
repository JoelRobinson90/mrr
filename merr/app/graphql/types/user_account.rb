# frozen_string_literal: true

module Types
  module UserAccount
    include Types::BaseInterface

    field :id, ID, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true

    orphan_types MedarriveAdminType, MedarriveCustomerSupportType, DemandCoordinatorType, FieldProviderType,
                 FieldAdminType, MedarriveClinicalOperationType, DefaultUserAccountType

    definition_methods do
      def resolve_type(object, _context)
        case object
        when MedarriveAdmin
          MedarriveAdminType
        when MedarriveCustomerSupport
          MedarriveCustomerSupportType
        when MedarriveClinicalOperation
          MedarriveClinicalOperationType
        when DemandCoordinator
          DemandCoordinatorType
        when FieldProvider
          FieldProviderType
        when FieldAdmin
          FieldAdminType
        else
          DefaultUserAccountType
        end
      end
    end
  end
end
