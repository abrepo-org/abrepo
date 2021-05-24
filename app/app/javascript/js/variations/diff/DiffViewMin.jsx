import React, {useState} from 'react';
import ReactDOM from 'react-dom';
import RenderDiff from './RenderDiff.jsx';

const DiffViewMin = (props) => {

    const [diff, setDiff] = useState(props.diff);

    return(
        <>

        <div className="is-size-7">
            {diff.selectorDisplayName || diff.selector}
        </div>

        {diff.calculated.text &&
         <div>{ RenderDiff(diff.id, diff.calculated.text) }</div>
        }

        {!diff.calculated.text && diff.calculated.css &&
         <div>{ RenderDiff(diff.id, diff.calculated.css) }</div>
        }

        </>
    )
};


export default DiffViewMin;
