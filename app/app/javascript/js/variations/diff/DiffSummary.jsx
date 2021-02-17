import React from 'react';

const DiffSummary = (props) => {

    if (!props.summary) return null;

    return(
        <div className="diff-summary is-flex is-align-items-baseline pt-2 pb-1">
          <span className={`${props.colorClass}`}>
            {props.icon}
          </span>
          <span className='pl-2'>
            {props.summary}
          </span>
        </div>
    );
};

export default DiffSummary;
