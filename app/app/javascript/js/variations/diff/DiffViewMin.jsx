import React, {useState} from 'react';
import ReactDOM from 'react-dom';
import { RenderDiff } from './RenderDiff.jsx';

const DiffViewMin = (props) => {

    const [diff, setDiff] = useState(props.diff);

    const selectRenderContent = (diff) => {

        if (diff.calculated.text) {
            return RenderDiff(diff.id, diff.calculated.text);
        }

        if (!diff.calculated.text && diff.calculated.css) {
            return RenderDiff(diff.id, diff.calculated.css);
        }

        if (diff.selectorDisplayName == "SCRIPT") {
            return (diff.summary_added || diff.summary_removed);
        }

        return null;
    }

    return(
        <>

        <div className="is-size-7">
            {diff.selectorDisplayName || diff.selector}
        </div>
        <div>
            { selectRenderContent(diff) }
        </div>
        </>
    )
};


export default DiffViewMin;
