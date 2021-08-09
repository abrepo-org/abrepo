import React, {useState} from 'react';
import ReactDOM from 'react-dom';
import { RenderDiff, RenderDiffAttrJSON } from './RenderDiff.jsx';

const ModalContent = (props) => {

    const [diff, setDiff] = useState(props.diff);

    return(
        <>
        {/* <div className='is-size-5 pb-2'>
            Details
            </div>
          */}
        <p>
            <div className="has-text-grey">Selector</div>
            <div>{diff.selectorDisplayName || diff.selector}</div>
        </p>

        {diff.calculated.text &&
         <p>
             <div className="has-text-grey">Text Diff</div>
             <div>{ RenderDiff(diff.id, diff.calculated.text) }</div>
         </p>
        }

         {diff.calculated.css &&
          <p>
              <div className="has-text-grey">CSS Diff</div>
              <div>{ RenderDiff(diff.id, diff.calculated.css) }</div>
          </p>
         }

         { diff.calculated.attrJSON &&
           <p>
               <div className="has-text-grey">Attr Diff</div>
               <div>{ RenderDiffAttrJSON(diff.id, diff.calculated.attrJSON) }</div>
           </p>
          }

          </>
    );
};

export default ModalContent;
