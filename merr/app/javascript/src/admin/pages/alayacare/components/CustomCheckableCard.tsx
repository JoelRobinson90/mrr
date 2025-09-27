import { EuiCheckableCard } from '@elastic/eui';
import styled from 'styled-components';

const CustomEuiCheckableCard = styled(EuiCheckableCard)`
  && {
    .euiCheckbox {
      .euiCheckbox__square,
      input {
        display: none;
      }
      &:after {
        content: '\\00a0\\00a0\\00a0';
        font-size: 20px;
        color: #474747;
        border-radius: 50px;
        padding: 0px 6px;
        border: 1px solid;
      }
    }
    &.euiCheckableCard-isChecked {
      .euiCheckbox {
        &:after {
          content: '\\2713';
        }
      }
    }
  }
`;

export default CustomEuiCheckableCard;
