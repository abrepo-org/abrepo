import React from 'react';
import ReactDOM from 'react-dom';
import Diff from './diff/Diff.jsx';
import DiffViewMinContainer from './diff/DiffViewMinContainer.jsx';

export default class DiffContainer extends React.Component {

    constructor(props) {
        super(props);
        console.log("DiffContainer");
    }

    render() {

        let minDiffs = [];
        let diffs = [];
        let textDiffs = [];

        //Filter diffPanel: min, true
        this.props.diffs.forEach( diff => {
            const cDiff = <Diff key={diff.id} diff={diff} {...this.props} />

            if(diff.diffPanel === "true" ) {
                diffs.push( cDiff );
            }

            if(diff.diffPanel === "min") {
                //text or style
                if (diff.calculated.text || ["SCRIPT"].includes(diff.selectorDisplayName) ) {
                    textDiffs.push( cDiff );
                } else {
                    minDiffs.push( cDiff );
                }
            }
        });


        return(
            <>
            <h4> Diffs </h4>
            { diffs }


            {!!textDiffs.length &&
                <DiffViewMinContainer title="Minor Content Changes">
                {textDiffs}
                </DiffViewMinContainer>
            }

            {!!minDiffs.length &&
                <DiffViewMinContainer title="Minor Style Changes">
                {minDiffs}
                </DiffViewMinContainer>
            }
            </>
        )
    }
}
