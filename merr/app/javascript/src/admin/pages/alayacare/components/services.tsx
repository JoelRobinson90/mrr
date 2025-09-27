import { EuiSpacer, EuiText } from '@elastic/eui';
import React from 'react';
import CustomEuiCheckableCard from './CustomCheckableCard';

export const Services = ({ services, selectedIds, onSelectService }) => (
  <>
    <EuiSpacer size="m" />
    <EuiText>
      <b>Please select services for this visit:</b>
    </EuiText>
    {services.map((service) => (
      <CustomEuiCheckableCard
        key={service.id}
        id={`service-${service.id}`}
        label={
          <EuiText>
            {service.name} - duration: {service.duration}
          </EuiText>
        }
        checkableType="checkbox"
        value="checkbox2"
        disabled={!service?.alayacare_id}
        checked={selectedIds.has(service.id)}
        onChange={() => {
          onSelectService(service);
        }}
      />
    ))}
  </>
);
