import React, {useState} from 'react';

export const RenderDiff = (id, parts) => {

    if (!parts) return null;

    //want to highlight blank spaces as the diff (instead of
    //indistinguishable blanks)
    const _formatText = (text, textStyle) => {

        if(!text) return text;

        if( RegExp(/^\s+$/).test(text) ) {
            return <pre style={textStyle}>"{text}"</pre>;
        }

        return text;
    };

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
        let renderText = part.value;

        if (parts.length == 1) {
            renderText = _formatText(part.value, textStyle);
        }

        return (
            <span key={`${id}-${i}`} style={textStyle}>
              {renderText}
            </span>
        );
    });


    return rendered;
};

export const RenderDiffAttrJSON = (id, attrJSON)  => {

    if(!Object.keys(attrJSON).length) return null;

    //render diff-parts as html
    let results = [];
    Object.entries(attrJSON).forEach( ([key, diff], i) =>  {

        const label =
        <span>{ i > 0 ? <><br/><br/></> : ''}
        {key}: &nbsp;
        </span>

        results.push(label);

        const result = diff.map( (part, i) => {
            const color = part.added ? 'green' :
                part.removed ? 'red' : 'grey';

            const textStyle= {
                color
            };

            return (
                <>
                  <span key={id+i} style={textStyle}>{part.value}</span>
                </>
            );
        });

        results.push(result);
    });

    if (results.length) return results;

};

export default { RenderDiff, RenderDiffAttrJSON };
