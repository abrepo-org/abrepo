import React from 'react';
import ReactDOM from 'react-dom';
import Diff from './Diff.jsx';

export default class DiffContainer extends React.Component {

    constructor(props) {
        super(props);
        console.log("DiffContainer");
    }

    render() {
        const diffs = this.props.diffs.map( (diff, i) => {
            return <Diff key={diff.id} diff={diff} {...this.props} />;
        });

        return(
            <div className="column">
                <h4> Diffs </h4>
                { diffs }
            </div>
        )
    }
}
