import React, { FC } from 'react';
import styled from 'styled-components';

const ContainerStyled = styled.div`
  display: block;
  text-align: center;
  background: #fff;
  border: 2.61017px solid #eeeff7;
  box-sizing: border-box;
  box-shadow: 0px 5.22034px 41.7627px rgba(189, 189, 189, 0.25);
  border-radius: 13.0508px;
  margin: auto;
  font-weight: bold;
  color: #6d6d6d;
  width: 100%;
  margin: 0 20px;
  @media (min-width: 400px) {
    display: flex;
    flex-wrap: wrap;
    width: max-content;
    margin: auto auto auto 20px;
  }
`;

const BadgesStyled = styled.div`
  width: auto;
  padding: 15px;
  border: 0 solid #eeeff7;
  border-bottom-width: 2.61017px;
  @media (min-width: 400px) {
    border-right-width: 2.61017px;
    border-bottom-width: 0;
  }

  &:last-child {
    border: none;
  }
`;
const ValueStyled = styled.p<{ color: string }>`
  margin-top: 8px;
  color: ${(props) => props.color};
`;

export interface TotalBadgesProps {
  data: { title: string; value: number; color: string }[];
}

export const TotalBadges: FC<TotalBadgesProps> = ({ data }) => {
  return (
    <ContainerStyled>
      {data.map((badge) => {
        return (
          <BadgesStyled key={badge.title}>
            {badge.title.toUpperCase()}
            <ValueStyled color={badge.color}>{badge.value}</ValueStyled>
          </BadgesStyled>
        );
      })}
    </ContainerStyled>
  );
};
