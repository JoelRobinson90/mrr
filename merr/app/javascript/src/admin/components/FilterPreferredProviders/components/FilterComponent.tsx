import styled from 'styled-components';
import { EuiFilterButton, EuiSelectable } from '@elastic/eui';

export const FilterButton = styled(EuiFilterButton)`
  &&& {
    background-color: #006de41a;
    border-radius: 6px;
    color: #005ec4;
    font-weight: 500;
    width: auto;
    .euiNotificationBadge {
      background-color: #006de41a;
      color: #0077cc;
      &--subdued {
        display: none;
      }
    }
  }
`;

export const Selectable = styled(EuiSelectable)`
  .euiSelectableListItem__append {
    display: none;
  }
  .euiSelectableList {
    animation: none !important;
  }
  .euiSelectableListItem-isFocused,
  .euiSelectableListItem:hover {
    background-color: inherit !important;
    color: #343741 !important;
    * {
      text-decoration: none !important;
    }
  }
  .euiCheckbox .euiCheckbox__input:checked + .euiCheckbox__square,
  .euiCheckbox .euiCheckbox__input:focus + .euiCheckbox__square {
    border-color: inherit;
    animation: none !important;
  }
  li[aria-selected='false'],
  li[aria-selected='true'] {
    .euiSelectableListItem__text::before {
      content: '';
      box-shadow: 0 2px 2px -1px rgba(152, 162, 179, 0.3);
      padding: 7px;
      border: 1px solid #c9cbcd;
      background: #fff;
      border-radius: 4px;
      transition: background-color 150ms ease-in, border-color 150ms ease-in;
      display: inline-block;
      position: absolute;
      left: 12px;
      top: 7px;
    }
  }
  li[aria-selected='true'] {
    .euiSelectableListItem__text::before {
      background: #006bb4;
    }

    .euiSelectableListItem__text::after {
      content: '';
      display: inline-block;
      transform: rotate(45deg);
      height: 9px;
      width: 6px;
      border-bottom: 2px solid white;
      border-right: 2px solid white;
      z-index: 100;
      position: absolute;
      top: 9px;
      left: 17px;
      border-radius: 1px;
    }
  }
`;
