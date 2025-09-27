import startCase from '../../src/helpers/startCase';

describe('startCase', () => {
  it('capitalizes the first letter of each word in a sentence', () => {
    const input = 'hello world';
    const expectedOutput = 'Hello World';

    expect(startCase(input)).toEqual(expectedOutput);
  });

  it('capitalizes the first letter of a single word', () => {
    const input = 'javascript';
    const expectedOutput = 'Javascript';

    expect(startCase(input)).toEqual(expectedOutput);
  });

  it('handles empty strings', () => {
    const input = '';
    const expectedOutput = '';

    expect(startCase(input)).toEqual(expectedOutput);
  });
});
