import React from 'react';
import { EuiText } from '@elastic/eui';
import { Survey } from '@/common/types';

type Props = {
  surveys: Survey[];
  hraStatus: string;
};

// TODO: remove HRA survey hacks when HRA survey logic is merged with Survey logic
export const AdditionalDataCollection: React.FC<Props> = ({ surveys, hraStatus }) => {
  const surveyStrings = surveys.map(
    (survey) => `${survey.meta.title || survey.name}: ${survey.responded ? 'Complete' : 'Pending'}`,
  );

  if (hraStatus !== 'Not Required') {
    surveyStrings.push(`SCAN HRA Survey: ${hraStatus}`);
  }

  if (surveyStrings.length === 0) {
    return <EuiText>N/A</EuiText>;
  }

  return (
    <EuiText>
      <ul>
        {surveyStrings.map((surveyString) => (
          <li key={surveyString}>{surveyString}</li>
        ))}
      </ul>
    </EuiText>
  );
};
