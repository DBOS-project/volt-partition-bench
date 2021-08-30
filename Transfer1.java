/* This file is part of VoltDB.
 * Copyright (C) 2008-2020 VoltDB Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */


import org.voltdb.SQLStmt;
import org.voltdb.VoltProcedure;
import org.voltdb.VoltTable;

public class Transfer1 extends VoltProcedure {

    // potential return codes (synced with client app)
    static final long VOTE_SUCCESSFUL = 0;
    static final long ERR_INVALID_ACCOUNT = 1;
    static final long ERR_VOTER_OVER_VOTE_LIMIT = 2;

    public final SQLStmt checkBalance = new SQLStmt(
            "SELECT balance FROM accounts WHERE acc_id = ?;");

    public final SQLStmt addBalance = new SQLStmt(
        "UPDATE accounts set balance = balance + ? WHERE acc_id = ?;");
    
    public final SQLStmt subBalance = new SQLStmt(
                "UPDATE accounts set balance = balance - ? WHERE acc_id = ?;");

    public long run(long fromAccountId, long amount) throws VoltAbortException {
        long toAccountId = fromAccountId;
        // Queue up validation statements
        // voltQueueSQL(checkBalance, EXPECT_ZERO_OR_ONE_ROW, fromAccountId);
        // voltQueueSQL(checkBalance, EXPECT_ZERO_OR_ONE_ROW, toAccountId);
        // VoltTable validation[] = voltExecuteSQL();

        // if (validation[0].getRowCount() == 0) {
        //     return ERR_INVALID_ACCOUNT;
        // }

        // if (validation[1].getRowCount() == 0) {
        //     return ERR_INVALID_ACCOUNT;
        // }

        // long fromAccountBalance = validation[0].asScalarLong();
        
        // if (fromAccountBalance < amount) {
        //     throw new VoltAbortException( "fromAccountBalance " + fromAccountBalance + " < amount " + amount);
        // }

        // Post the vote
        voltQueueSQL(subBalance, amount, fromAccountId);
        voltExecuteSQL();
        voltQueueSQL(addBalance, amount, toAccountId);
        voltExecuteSQL(true);

        // Set the return value to 0: successful vote
        return VOTE_SUCCESSFUL;
    }
}
