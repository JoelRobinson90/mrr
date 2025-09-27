import { ReactElement } from 'react';

import { render, fireEvent, RenderResult } from '@testing-library/react';

export interface RenderComponentResult extends RenderResult {
  fillInput: (label: string, value: string) => Promise<boolean>;
  clickLink: (text: string) => Promise<boolean>;
}

// Render a test component and make helper methods for easier interactions
export const renderComponent = (component: ReactElement): RenderComponentResult => {
  const wrapper = render(component);

  const { findByPlaceholderText, findByText } = wrapper;

  const fillInput = async (label: string, value: string): Promise<boolean> =>
    fireEvent.change(await findByPlaceholderText(label), { target: { value } });

  const clickLink = async (text: string): Promise<boolean> => fireEvent.click(await findByText(text));

  return { fillInput, clickLink, ...wrapper };
};
