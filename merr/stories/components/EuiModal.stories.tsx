import { MedSelect, MedTextArea } from '@/common/components/forms';
import {
  EuiButton,
  EuiButtonEmpty,
  EuiConfirmModal,
  EuiFlexGroup,
  EuiFlexItem,
  EuiForm,
  EuiHorizontalRule,
  EuiModal,
  EuiModalBody,
  EuiModalFooter,
  EuiModalHeader,
  EuiModalHeaderTitle,
  EuiOverlayMask,
  EuiSpacer,
  EuiText,
} from '@elastic/eui';
import { Meta } from '@storybook/react';
import React, { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';

export default {
  title: 'Components/EuiModal',
  component: EuiModal,
} as Meta;

export const CustomModalWithForm = () => {
  const [modalVisible, setModalVisible] = useState(false);

  const form = useForm();

  const onSubmit = (values) => {
    alert(JSON.stringify(values));
    closeModal();
  };

  const showModal = () => setModalVisible(true);
  const closeModal = () => setModalVisible(false);

  let modal;
  if (modalVisible) {
    modal = (
      <EuiOverlayMask onClick={closeModal}>
        <EuiModal onClose={closeModal} initialFocus="[name=field1]">
          <EuiModalHeader>
            <EuiModalHeaderTitle>Invite MedArrive Users</EuiModalHeaderTitle>
          </EuiModalHeader>

          {/* Horizontal rule + spacer make a nice line under the header */}
          <EuiHorizontalRule margin="none" />
          <EuiSpacer size="m" />

          {/* Form wraps the modal body and footer to include submit button */}
          <form onSubmit={form.handleSubmit(onSubmit)}>
            <FormProvider {...form}>
              <EuiModalBody>
                <EuiForm>
                  <MedSelect
                    name="role"
                    label="Select Permissions"
                    options={[
                      { value: 'support', text: 'Customer Support' },
                      { value: 'clinical', text: 'Clinical Support' },
                      { value: 'admin', text: 'MedArrive Admin' },
                    ]}
                  />

                  <MedTextArea name="emails" label="Emails (comma separated)" rows={3} />
                </EuiForm>
              </EuiModalBody>

              <EuiModalFooter>
                {/* Pulls the Close button to the left */}
                <EuiFlexGroup justifyContent="spaceBetween" responsive={false}>
                  <EuiFlexItem grow={false}>
                    <EuiButtonEmpty color="text" flush="left" iconType="cross" onClick={closeModal}>
                      Close
                    </EuiButtonEmpty>
                  </EuiFlexItem>
                  <EuiFlexItem grow={false}>
                    <EuiButton fill color="secondary" type="submit">
                      Save
                    </EuiButton>
                  </EuiFlexItem>
                </EuiFlexGroup>
              </EuiModalFooter>
            </FormProvider>
          </form>
        </EuiModal>
      </EuiOverlayMask>
    );
  }

  return (
    <>
      <EuiButton onClick={showModal}>Show modal</EuiButton>

      {modal}
    </>
  );
};

export const ConfirmModals = () => {
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [isDestroyModalVisible, setIsDestroyModalVisible] = useState(false);
  const [isEmptyModalVisible, setIsEmptyModalVisible] = useState(false);
  const [isButtonDisabledModalVisible, setIsButtonDisabledModalVisible] = useState(false);

  const closeModal = () => setIsModalVisible(false);
  const showModal = () => setIsModalVisible(true);

  const closeDestroyModal = () => setIsDestroyModalVisible(false);
  const showDestroyModal = () => setIsDestroyModalVisible(true);

  const closeEmptyModal = () => setIsEmptyModalVisible(false);
  const showEmptyModal = () => setIsEmptyModalVisible(true);

  const closeButtonDisabledModal = () => setIsButtonDisabledModalVisible(false);
  const showButtonDisabledModal = () => setIsButtonDisabledModalVisible(true);

  let modal;

  if (isModalVisible) {
    modal = (
      <EuiConfirmModal
        title="Do this thing"
        onCancel={closeModal}
        onConfirm={closeModal}
        cancelButtonText="No, don't do it"
        confirmButtonText="Yes, do it"
        defaultFocusedButton="confirm"
      >
        <p>You&rsquo;re about to do something.</p>
        <p>Are you sure you want to do this?</p>
      </EuiConfirmModal>
    );
  }

  let destroyModal;

  if (isDestroyModalVisible) {
    destroyModal = (
      <EuiConfirmModal
        title="Do this destructive thing"
        onCancel={closeDestroyModal}
        onConfirm={closeDestroyModal}
        cancelButtonText="No, don't do it"
        confirmButtonText="Yes, do it"
        buttonColor="danger"
        defaultFocusedButton="confirm"
      >
        <p>You&rsquo;re about to destroy something.</p>
        <p>Are you sure you want to do this?</p>
      </EuiConfirmModal>
    );
  }

  let emptyModal;

  if (isEmptyModalVisible) {
    emptyModal = (
      <EuiConfirmModal
        title="Do this thing"
        onCancel={closeEmptyModal}
        onConfirm={closeEmptyModal}
        cancelButtonText="No, don't do it"
        confirmButtonText="Yes, do it"
        defaultFocusedButton="confirm"
      />
    );
  }

  let buttonDisabledModal;

  if (isButtonDisabledModalVisible) {
    buttonDisabledModal = (
      <EuiConfirmModal
        title="My button is disabled"
        onCancel={closeButtonDisabledModal}
        onConfirm={closeButtonDisabledModal}
        cancelButtonText="No, don't do it"
        confirmButtonText="Yes, do it"
        defaultFocusedButton="cancel"
        confirmButtonDisabled={true}
      />
    );
  }

  return (
    <div>
      <EuiText>
        <p>Simple modals with an easier syntax</p>
      </EuiText>
      <EuiSpacer size="s" />

      <EuiFlexGroup wrap gutterSize="xs">
        <EuiFlexItem grow={false}>
          <EuiButton onClick={showModal}>Show confirm modal</EuiButton>
        </EuiFlexItem>
        <EuiFlexItem grow={false}>
          <EuiButton onClick={showDestroyModal}>Show dangerous confirm modal</EuiButton>
        </EuiFlexItem>
        <EuiFlexItem grow={false}>
          <EuiButton onClick={showEmptyModal}>Show title-only confirm modal</EuiButton>
        </EuiFlexItem>
        <EuiFlexItem grow={false}>
          <EuiButton onClick={showButtonDisabledModal}>Show confirm disabled confirm modal</EuiButton>
        </EuiFlexItem>
      </EuiFlexGroup>
      {modal}
      {destroyModal}
      {emptyModal}
      {buttonDisabledModal}
    </div>
  );
};
