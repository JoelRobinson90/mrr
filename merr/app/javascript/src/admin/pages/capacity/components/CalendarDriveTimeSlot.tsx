import { DriveTimeCalendarEvent } from '@/common/types';
import React, { FC } from 'react';
import styled from 'styled-components';

const DriveTimeContainer = styled.div`
  max-width: 100%;
  min-height: 63px;
  display: flex;
  align-items: center;
`;

const Line = styled.span`
  display: block;
  width: 100%;
  background: #0077cc;
  text-align: center;
  height: 1px;
  position: relative;
`;

interface LabelProps {
  labelPosition?: string;
}

const Label = styled.span<LabelProps>`
  display: inline-block;
  color: rgb(52, 55, 65);
  font-size: 10px;
  position: absolute;
  top: -14px;
  font-weight: 500;
  width: 60px;
  left: ${(props) => props.labelPosition};
`;

type DriveTimeSlotProps = {
  event: DriveTimeCalendarEvent;
};

export const DriveTimeSlot: FC<DriveTimeSlotProps> = ({ event }) => {
  const visit = event?.original;
  const isShortDriveTime = visit.drive_time < 30;
  const labelPosition = isShortDriveTime ? '-15px' : '50%';
  return (
    <DriveTimeContainer>
      <Line>
        <Label labelPosition={labelPosition}>{visit.title}</Label>
      </Line>
    </DriveTimeContainer>
  );
};
