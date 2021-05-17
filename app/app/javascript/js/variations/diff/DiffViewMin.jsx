import React, {useState} from 'react';
import ReactDOM from 'react-dom';
import RenderDiff from './RenderDiff.jsx';

const DiffViewMin = (props) => {

    const [diff, setDiff] = useState(props.diff);

    return(
        <>

        {  !diff.newDim.isVisible &&
           !diff.origDim.isVisible &&
           <div className="has-text-grey is-size-7">
               Not Visible
           </div>
        }

        <div className="is-size-7">
            {diff.selectorDisplayName || diff.selector}
        </div>

        {diff.calculated.css &&

         <div>{ RenderDiff(diff.id, diff.calculated.css) }</div>

        }

        </>
    )
};


export default DiffViewMin;
