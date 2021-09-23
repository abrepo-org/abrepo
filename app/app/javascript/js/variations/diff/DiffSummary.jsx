import React from 'react';

const DiffSummary = (props) => {

    if (!props.summary) return null;

    return(
        <div className="diff-summary is-flex is-align-items-baseline pt-2 pb-1">
          <div className={`${props.colorClass}`}>
            {props.icon}
          </div>
          <div className='diff-summary summary-text pl-2'>
            {props.summary}
          </div>
        </div>
    );
};

export default DiffSummary;
