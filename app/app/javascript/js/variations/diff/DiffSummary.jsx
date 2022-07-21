import React from 'react';

const DiffSummary = (props) => {

    if (!props.summary) return null;

    //TODO: add notes highlighting detection (abanno) and render functions (here)
    const format_css = (diff, summary_delta, summary, summary_format) => {

        if (!summary_format) return summary;

        if (!summary_format.toLocaleLowerCase().includes('css')) return summary;

        summary = summary.split(";").join(';<br/>');

        return summary;
    };

    /*
     * replaces css text 'rgb(...' with icon and color
     */
    const format_rgb_css = (summary) => {

        if (!summary.includes('rgb(')) return summary;

        const cssRegExp = /(rgb\(\s*\d+,\s*\d+,\s*\d+\));?/;

        const s = summary.split(cssRegExp);

        let flag = false;
        for (let i = 0; i < s.length; i++) {

            if (s[i].includes('rgb') ) {
                const rgb = s[i];
                const style = { backgroundColor: rgb };
                s[i-1] = <span>{s[i-1]}</span>;
                s[i] =
                    <>
                    <span className='cssbox'
                          title={rgb} style={style}>&nbsp;&nbsp;</span>
                    <span>{rgb}</span>
                    <br/>
                    </>;

                flag = true;
            }

        }

        if (flag) return s;

        return summary;
    };

    //display only
    //values are taken from summary.results
    const format_truncate = (text, skip)  => {
        //diff.calculated.text-> []
        //diff.diffSummary.manual_summarization -> {delta, added, removed}

        if (skip) return text;

        //these are arbitrary
        const WHOLE_TRUNC_LEN = 200;
        const NEUTRAL_TRUNC_LEN = 25;
        const ELLIPSIS = ". . .";

        const diff = props.diff;
        let texts = diff.calculated && diff.calculated.text;


        // 1. Remove danging neutral
        const trunc = (text !== null) && !(text => /[£$€¥]/.test(text));
        if (!trunc) {
            console.log("[format_truncate()] currency detecting,\
                        skipping dangling neutral truncation");
        }

        if (trunc && texts && texts.length) {
            const last = texts[texts.length - 1];
            const i = text.lastIndexOf(last.value);

            if (!last.added && !last.removed && (i != -1)) {
                text = text.substring(0, i).trim();
            }
        }

        // too small, don't bother truncating
        // 2. if < WHOLE_TRUNC_LEN len, return text
        if (text && (text.length < WHOLE_TRUNC_LEN) ) return text;

        // 3. decide to truncate text if diff.calculated neutral text exists in summaryq
        // e.g. not css, or some other generated grammar
        //summary needs to match calculated neutral components
        const isTruncable = texts && texts.length && texts.every( diff_text => {
            const isNeutral = !diff_text['added'] && !diff_text['removed'];
            if(isNeutral) {
                return text.includes(diff_text.value);
            }
            return true;
        });

        if (!isTruncable) return text;

        // 4. Truncate neutrals
        texts && texts.forEach( diff_text => {
            const isNeutral = !diff_text['added'] && !diff_text['removed'];

            if(isNeutral) {
                const i = text.indexOf(diff_text.value);

                if (i != -1 && diff_text.value.length > NEUTRAL_TRUNC_LEN) {

                    const diff_text_words = diff_text.value.split(" ");
                    const first = diff_text_words[0];
                    const last = diff_text_words.slice(-1);

                    //replace content with ellipsis
                    if (first.length && last.length) {
                        text = text.replace(diff_text.value,
                                            [first, ELLIPSIS, last].join(" "));
                    }
                }
            }
        });

        if (text.length > WHOLE_TRUNC_LEN) {
            return [text.substring(0, WHOLE_TRUNC_LEN), ELLIPSIS].join(" ");
        }

        return text;
    };


    {
        /*
         * RENDER
         * NB: props.detail is set false for Modal
         */
    }

    let summary = format_truncate( props.summary, !props.detail );
    try {
        summary = format_css(props.diff, props.diff.summary_delta, summary, props.summary_format);
        summary = format_rgb_css(summary);
    } catch(e) {
        console.error("format_css err");
    }

    const renderSummary =(summary, summary_format) => {

        if (summary_format == "css") {
            return(
                <div className='diff-summary summary-text pl-2'
                     dangerouslySetInnerHTML={{__html: summary}}>
                </div>
            );
        }

        return(
            <div className='diff-summary summary-text pl-2'>
              {summary}
            </div>
        );

    };

    const paddingTop = props.nonVisible ? "pt-1" : "pt-2";

    return(
        <div className={`diff-summary is-flex is-align-items-baseline ${paddingTop} pb-1`}>
          <div className={`${props.colorClass}`}>
            {props.icon}
          </div>
          {renderSummary(summary, props.summary_format)}
        </div>
    );
};

export default DiffSummary;
