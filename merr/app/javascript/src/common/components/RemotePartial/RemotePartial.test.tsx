import { render } from '@testing-library/react';
import React from 'react';
import { registerPartials, RemotePartial } from './RemotePartial';

describe('<RemotePartial />', () => {
  const oldFetch = window.fetch;

  beforeEach(() => {
    delete window.fetch;
  });

  afterEach(() => {
    window.fetch = oldFetch;
  });

  type TestPartialProps = {
    backEndMessage: string;
    frontEndMessage: string;
  };

  const TestPartial: React.FC<TestPartialProps> = ({ backEndMessage, frontEndMessage }) => {
    return (
      <div>
        <div data-testid="test-partial-backEndMessage">{backEndMessage}</div>
        <div data-testid="test-partial-frontEndMessage">{frontEndMessage}</div>
      </div>
    );
  };
  registerPartials({ TestPartial });

  describe('with a valid response', () => {
    const path = '/path/to/test/partial';

    const fetchMock = jest.fn(() =>
      Promise.resolve({
        status: 200,
        json: () =>
          Promise.resolve({
            componentName: 'TestPartial',
            componentProps: {
              backEndMessage: 'Hello remote partial!',
            },
          }),
      }),
    );

    beforeEach(() => {
      // @ts-ignore
      window.fetch = fetchMock;
    });

    it('fetches the JSON response and renders the component', async () => {
      const { findByTestId } = render(<RemotePartial path={path} />);

      expect(await findByTestId('test-partial-backEndMessage')).toHaveTextContent('Hello remote partial!');
      expect(await findByTestId('test-partial-frontEndMessage')).toBeEmptyDOMElement();
      expect(fetchMock).toHaveBeenCalledWith(path);
    });

    it('passes partialProps to the partial component', async () => {
      const { findByTestId } = render(
        <RemotePartial
          path={path}
          partialProps={{
            frontEndMessage: 'This is coming from the parent',
          }}
        />,
      );

      expect(await findByTestId('test-partial-frontEndMessage')).toHaveTextContent('This is coming from the parent');
    });
  });
});
