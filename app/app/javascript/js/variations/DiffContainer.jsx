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

        //Filter diffPanel: min, true
        this.props.diffs.forEach( diff => {
            if(diff.diffPanel === "min") minDiffs.push(diff);
            if(diff.diffPanel === "true" ) diffs.push(diff);
        });


        diffs = diffs.map( (diff, i) => {
            return <Diff key={diff.id} diff={diff} {...this.props} />;
        });

        minDiffs = minDiffs.map( (diff, i) => {
            return <Diff key={diff.id} diff={diff} {...this.props} />;
        });

        return(
            <>
              <h4> Diffs </h4>
              { diffs }

              <DiffViewMinContainer>
                  {minDiffs}
              </DiffViewMinContainer>
            </>
        )
    }
}
