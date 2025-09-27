import styled from 'styled-components';

const ImgStyled = styled.img`
  position: absolute;
  opacity: 0.1;
  z-index: -1;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  @media screen and (max-width: 767px) {
    display: none;
  }
`;

export const DarkBlue = styled(ImgStyled)`
  margin: 0 0 0 auto;
`;

export const GreenDrop = styled(ImgStyled)`
  margin: auto 35% 10% auto;
`;

export const GreenMountain = styled(ImgStyled)`
  margin: auto auto 0 30%;
`;

export const LightBlue = styled(ImgStyled)`
  margin: auto auto auto 0;
`;
