import { BaseModel } from './index';

export interface Survey extends BaseModel {
  name: string;
  meta: SurveyMetaData;
  responded_at: string | null;
  responded: boolean;
  template?: SurveyTemplateItem[];
  response?: SurveyResponse;
}

export type SurveyResponse = { [qId: string]: SurveyResponseItem };

export interface SurveyResponseItem {
  q: string;
  a?: string;
}

export interface SurveyMetaData {
  title: string;
}

export type SurveyTemplateItem =
  | SurveyTemplateContentItem
  | SurveyTemplateSelectItem
  | SurveyTemplateSuperSelectItem
  | SurveyTemplateTextInputItem;

export type SurveyTemplateContentItem = {
  type: 'content';
  content: string;
};

export type SurveyTemplateSelectItem = {
  type: 'select';
  id: string;
  question: string;
  options: {
    text: string;
    value?: string;
  }[];
};

export type SurveyTemplateSuperSelectItem = {
  type: 'super_select';
  id: string;
  question: string;
  options: {
    text: string;
    subtext: string;
    value?: string;
  }[];
};

export type SurveyTemplateTextInputItem = {
  type: 'text_input';
  id: string;
  question: string;
};
