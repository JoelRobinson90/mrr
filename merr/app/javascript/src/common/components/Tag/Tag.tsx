import { EuiBadge } from '@elastic/eui';
import React from 'react';
import styled from 'styled-components';
import { Tag } from '@/common/types';

interface Props {
  tag: Tag;
}

const TagStyled = styled(EuiBadge)`
  && {
    margin: auto 8px;
    padding: 6px 12px;
    border-radius: 50px;
    font-size: 14px;
  }
`;

export const TagLabel: React.FC<Props> = ({ tag }) => {
  return <TagStyled color={tag.color}>{tag.name}</TagStyled>;
};
