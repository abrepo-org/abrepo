import React, {useState} from 'react';
import ReactDOM from 'react-dom';

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
             <div>{ renderDiff(diff.id, diff.calculated.text) }</div>
         </p>
        }

         {diff.calculated.css &&
          <p>
              <div className="has-text-grey">CSS Diff</div>
              <div>{ renderDiff(diff.id, diff.calculated.css) }</div>
          </p>
         }

          </>
    );
};
//diff
//calculated: {text, css, attr>
//diffType: "CHANGED"



const renderDiff = (id, parts) => {

    if (!parts) return null;

    const rendered = parts.map( (part,i) => {

        const color = part.added ? 'green' :
                      part.removed ? 'red' : 'grey';

        const textStyle= { color };

        //truncate long grey bits that don't show a diff
        if (color=='grey' && part.value.length > 100) {

            part.value = [part.value.substring(0, 40),
                          ". . . ",
                          part.value.substring(part.value.length - 40)].join('');
        }

        //bug where a blank in middle of long text will be
        //rendered as formattedText
        let renderText = part.value

        if (parts.length == 1) {
            renderText = _formatText(part.value, textStyle);
        }

        return (
            <span key={`${id}-${i}`} style={textStyle}>
                {renderText}
            </span>
        )
    });


    //want to highlight blank spaces as the diff (instead of
    //indistinguishable blanks)
    const _formatText = (text, textStyle) => {

        if(!text) return text;

        if( RegExp(/^\s+$/).test(text) ) {
            return <pre style={textStyle}>"{text}"</pre>
        }

        return text
    }

    return rendered;
};


export default ModalContent;
