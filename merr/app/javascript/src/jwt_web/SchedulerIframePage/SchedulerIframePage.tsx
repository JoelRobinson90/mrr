import { gql, useLazyQuery, useQuery } from '@apollo/client';
import React, { useMemo, useEffect } from 'react';
import { withJwtWebLayout } from '../JwtWebLayout/JwtWebLayout';
import queryString from 'query-string';
import { ScheduleVisitPageComponent } from '@/admin/pages/scheduling/ScheduleVisitPage';
import { EuiCallOut, EuiLoadingContent } from '@elastic/eui';
import moment from 'moment';

const SCHEDULER_IFRAME_PAGE_QUERY = gql`
  query SchedulerIframePageQuery($patientMaId: ID!, $programMaId: ID, $includeProgram: Boolean!) {
    getPatient(maId: $patientMaId) {
      id
    }
    getProgram(maId: $programMaId) @include(if: $includeProgram) {
      id
    }
  }
`;

const SCHEDULER_IFRAME_RESCHEDULE_QUERY = gql`
  query SchedulerIframeRescheduleQuery($visitMaId: ID!) {
    getVisit(maId: $visitMaId) {
      id
      externalId
      patientId
      programId
      visitTypeId
      serviceIds
      cxStart
      cxEnd
      fieldProviderId
    }
  }
`;

type SchedulerMode = 'new' | 'reschedule';

type SchedulerIframePageProps = {
  mode: SchedulerMode;
};

type UsePreloadSchedulerDataResult = {
  schedulerProps: {
    patient_id: string;
    visit_id?: string;
    external_id?: string;
    program_id?: string;
    visit_type_id?: string;
    duration?: number;
    service_ids?: string[];
    existing_visit_alayacare_id?: string;
    fp_id?: string;
    iframe?: boolean;
  };
  loading: boolean;
  redirect: boolean;
  error: any;
};

const usePreloadSchedulerData = (mode: SchedulerMode): UsePreloadSchedulerDataResult => {
  const currentParams = useMemo(() => queryString.parse(location.search), []);
  const { patient_ma_id, program_ma_id, patient_id, visit_ma_id } = currentParams;

  // If MA IDs present, fetch primary IDs via gql and redirect with new query params
  // If patient_id query param present, assume this is already done

  if (patient_id) {
    return {
      schedulerProps: {
        patient_id: patient_id.toString(),
      },
      loading: false,
      redirect: false,
      error: false,
    };
  }

  if (mode === 'new') {
    const { data, error, loading } = useQuery(SCHEDULER_IFRAME_PAGE_QUERY, {
      variables: {
        patientMaId: patient_ma_id,
        programMaId: program_ma_id,
        includeProgram: !!program_ma_id,
      },
    });
    const patient = data?.getPatient;
    const program = data?.getProgram;
    const redirect = !!data?.getPatient?.id;

    let errorMsg;
    if (!loading && !patient) {
      errorMsg = `Patient ${patient_ma_id} not found`;
    }

    return {
      schedulerProps: {
        patient_id: patient?.id,
        program_id: program?.id,
      },
      redirect,
      loading: true,
      error: errorMsg || error,
    };
  } else if (mode === 'reschedule') {
    const { data, error, loading } = useQuery(SCHEDULER_IFRAME_RESCHEDULE_QUERY, {
      variables: { visitMaId: visit_ma_id },
    });
    const visit = data?.getVisit;
    const redirect = !!visit;

    let errorMsg;
    if (!loading && !visit) {
      errorMsg = `Visit ${visit_ma_id} not found`;
    }

    return {
      schedulerProps: visit
        ? {
            patient_id: visit.patientId,
            program_id: visit.programId,
            visit_type_id: visit.visitTypeId,
            duration: moment(visit.cxEnd).diff(moment(visit.cxStart), 'minutes'),
            service_ids: visit.serviceIds,
            external_id: visit.externalId,
            fp_id: visit.fieldProviderId,
          }
        : { patient_id: '' },
      redirect,
      loading: true,
      error: errorMsg || error,
    };
  }
};

const SchedulerIframePageComponent: React.FC<SchedulerIframePageProps> = ({ mode }) => {
  const { schedulerProps, loading, error, redirect } = usePreloadSchedulerData(mode);
  const { patient_id } = schedulerProps;

  useEffect(() => {
    if (redirect) {
      const query = queryString.stringify({
        ...schedulerProps,
        iframe: 1,
      });
      window.location.search = query;
    }
  }, [redirect]);

  if (error) {
    return (
      <EuiCallOut title="Error" color="danger">
        <p>{error}</p>
      </EuiCallOut>
    );
  }

  if (loading) {
    return <EuiLoadingContent />;
  }

  if (!patient_id) {
    return (
      <EuiCallOut title="Error" color="danger">
        <p>Patient not found.</p>
      </EuiCallOut>
    );
  }

  return <ScheduleVisitPageComponent patient_id={patient_id} modalRedirectPath={window.location.pathname} />;
};

export const SchedulerIframePage = withJwtWebLayout(SchedulerIframePageComponent);
