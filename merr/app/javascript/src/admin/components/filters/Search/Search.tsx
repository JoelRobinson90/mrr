import React, { ReactNode } from 'react';
import styled from 'styled-components';

import { EuiFieldSearch } from '@elastic/eui';

const FilterContainerStyled = styled.div<FilterContainerProps>`
  && {
    display: block;
    @media (min-width: ${(props) => props.media}px) {
      display: flex;
      width: 100%;
    }
  }
`;

const FieldSearchStyled = styled(EuiFieldSearch)`
  height: 42px;
`;

const SearchContainerStyled = styled.div<FilterContainerProps>`
  margin-right: 10px;
  margin-top: 10px;
  max-width: 350px;
  @media (min-width: ${(props) => props.media}px) {
    width: ${(props) => props.width}%;
  }
`;

interface FilterContainerProps {
  media: string;
  width?: string;
}

export interface SearchProps extends FilterContainerProps {
  query: string;
  onSearch: (query: string) => void;
  children: ReactNode;
}

export const Search: React.FC<SearchProps> = ({ query, onSearch, children, media, width = '40' }) => {
  return (
    <FilterContainerStyled media={media}>
      <SearchContainerStyled media={media} width={width}>
        <FieldSearchStyled
          placeholder="Search..."
          isClearable={true}
          defaultValue={query}
          fullWidth={true}
          onSearch={onSearch}
        />
      </SearchContainerStyled>
      <div>{children}</div>
    </FilterContainerStyled>
  );
};
