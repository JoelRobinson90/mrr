import {
  EuiButtonEmpty,
  EuiContextMenuItem,
  EuiContextMenuPanel,
  EuiFlexGroup,
  EuiFlexItem,
  EuiPagination,
  EuiPopover,
} from '@elastic/eui';
import React, { useState } from 'react';

export interface PaginationFooterProps {
  perPage: number;
  pageCount: number;
  activePage: number;
  onPageClick: (page: number, perPage: number) => void;
  rowMenuSelections?: number[];
}

const ROW_MENU_SELECTIONS = [25, 50, 75, 100];

export const PaginationFooter: React.FC<PaginationFooterProps> = ({
  perPage,
  pageCount,
  activePage,
  onPageClick,
  rowMenuSelections = ROW_MENU_SELECTIONS,
}) => {
  const [isPopoverOpen, setIsPopoverOpen] = useState(false);

  const onButtonClick = () => setIsPopoverOpen((val) => !val);
  const closePopover = () => setIsPopoverOpen(false);

  const closeRowsPopoverAndReset = (newPerPage) => {
    closePopover();
    onPageClick(1, newPerPage);
  };

  const rowsButton = (
    <EuiButtonEmpty
      size="s"
      color="text"
      iconType="arrowDown"
      iconSide="right"
      onClick={onButtonClick}
      style={{ color: '#343741', fontSize: '14px' }}
    >
      Rows per page: {perPage}
    </EuiButtonEmpty>
  );

  const rowsMenuItems = rowMenuSelections.map((n) => (
    <PerPageMenuItem key={n.toString()} perPage={n} isSelected={perPage === n} onClick={closeRowsPopoverAndReset} />
  ));

  return (
    <EuiFlexGroup justifyContent="spaceBetween" alignItems="center">
      <EuiFlexItem grow={false}>
        <EuiPopover button={rowsButton} isOpen={isPopoverOpen} closePopover={closePopover} panelPaddingSize="none">
          <EuiContextMenuPanel items={rowsMenuItems} />
        </EuiPopover>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiPagination
          pageCount={pageCount}
          activePage={activePage - 1}
          onPageClick={(page) => onPageClick(page + 1, perPage)}
        />
      </EuiFlexItem>
    </EuiFlexGroup>
  );
};

const PerPageMenuItem: React.FC<{
  perPage: number;
  isSelected: boolean;
  onClick: (number) => void;
}> = ({ perPage, isSelected, onClick }) => {
  return (
    <EuiContextMenuItem icon={isSelected ? 'check' : 'empty'} onClick={() => onClick(perPage)}>
      {perPage} rows
    </EuiContextMenuItem>
  );
};
